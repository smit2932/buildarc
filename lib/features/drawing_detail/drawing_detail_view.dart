import 'dart:ui';

import 'package:ardennes/features/drawing_detail/views/drawing_detail_pullup_navigation.dart';
import 'package:ardennes/features/drawing_detail/views/drawing_detail_side_navigation.dart';
import 'package:ardennes/features/drawing_detail/views/undo_redo_stack.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_event.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/core_ui/canvas/color_palette.dart';
import 'package:ardennes/libraries/core_ui/canvas/drawing_canvas.dart';
import 'package:ardennes/libraries/core_ui/canvas/drawing_mode.dart';
import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:ardennes/libraries/core_ui/icon_box/icon_box.dart';
import 'package:ardennes/libraries/core_ui/window_size/window_size_calculator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../libraries/account_context/state.dart';
import 'drawing_detail_bloc.dart';
import 'drawing_detail_state.dart';

class DrawingDetailScreen extends StatefulWidget {
  final String number;
  final String collection;
  final String projectId;
  final int versionId;

  const DrawingDetailScreen(
      {super.key,
      required this.number,
      required this.collection,
      required this.projectId,
      required this.versionId});

  @override
  State<StatefulWidget> createState() => DrawingDetailScreenState();
}

class DrawingDetailScreenState extends State<DrawingDetailScreen> {
  final GlobalKey<SheetWidgetState> sheetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final accountContextState = context.watch<AccountContextBloc>().state;
    final drawingsCatalogBloc = context.read<DrawingsCatalogBloc>();

    if (accountContextState is AccountContextLoadedState) {
      final selectedProject = accountContextState.selectedProject;
      if (selectedProject != null) {
        drawingsCatalogBloc.add(FetchDrawingsCatalogEvent(selectedProject));
      }
    }
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () {
                sheetKey.currentState?._fitToView();
              }),
        ],
        title: const Text('Drawing Detail'),
      ),
      body: BlocBuilder<DrawingDetailBloc, DrawingDetailState>(
        builder: (context, state) {
          final windowSize = WindowSizeCalculator.getWindowSize(context);
          if (kIsWeb && windowSize == WindowSize.expanded) {
            return Row(children: [
              const SideNavigation(),
              Expanded(
                child: SheetWidget(
                  key: sheetKey,
                  state: state,
                  versionId: widget.versionId,
                ),
              ),
            ]);
          } else {
            return Stack(children: [
              Positioned.fill(
                  child: SheetWidget(
                key: sheetKey,
                state: state,
                versionId: widget.versionId,
              )),
              const PullUpWindowSizeNavigation(),
            ]);
          }
        },
      ),
    );
  }
}

class SheetWidget extends StatefulHookWidget {
  final DrawingDetailState state;
  final int versionId;

  const SheetWidget({
    Key? key,
    required this.state,
    required this.versionId,
  }) : super(key: key);

  @override
  SheetWidgetState createState() => SheetWidgetState();
}

class SheetWidgetState extends State<SheetWidget>
    with TickerProviderStateMixin {
  final TransformationController controller = TransformationController();
  late AnimationController controllerReset;

  @override
  void initState() {
    super.initState();
    controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final isScaling = useState(false);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final undoRedoStack = useState(
      UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );

    final state = widget.state;
    if (state is DrawingDetailStateLoading) {
      return const CircularProgressIndicator();
    } else if (state is DrawingDetailStateLoaded) {
      final backgroundImage = useState<Image?>(state.image);
      return Container(
          color: Colors.grey[300],
          child: Stack(
            children: [
              InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 16.0,
                  boundaryMargin: const EdgeInsets.all(20.0),
                  transformationController: controller,
                  // scaleEnabled: false,
                  panEnabled: false,
                  onInteractionStart: (ScaleStartDetails details) {
                    // Handle interaction start
                  },
                  onInteractionUpdate: (ScaleUpdateDetails details) {
                    // Handle interaction update
                    if (details.scale != 1.0) {
                      isScaling.value = true;
                    }
                  },
                  onInteractionEnd: (ScaleEndDetails details) {
                    if (isScaling.value) {
                      isScaling.value = false;
                    }
                  },
                  child: Center(
                      child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    color: Colors.transparent,
                    child: DrawingCanvas(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      drawingMode: drawingMode,
                      selectedColor: selectedColor,
                      strokeSize: strokeSize,
                      eraserSize: eraserSize,
                      currentSketch: currentSketch,
                      allSketches: allSketches,
                      canvasGlobalKey: canvasGlobalKey,
                      filled: filled,
                      isScaling: isScaling,
                      polygonSides: polygonSides,
                      backgroundImage: backgroundImage,
                    ),
                  ))),
              Positioned(
                  right: 25, // Adjust as needed
                  top: 10, // Adjust as needed
                  child: Column(
                    children: [
                      IconBox(
                        iconData: FontAwesomeIcons.pencil,
                        selected: drawingMode.value == DrawingMode.pencil,
                        onTap: () => drawingMode.value = DrawingMode.pencil,
                        tooltip: 'Pencil',
                      ),
                      IconBox(
                        selected: drawingMode.value == DrawingMode.line,
                        onTap: () => drawingMode.value = DrawingMode.line,
                        tooltip: 'Line',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22,
                              height: 2,
                              color: drawingMode.value == DrawingMode.line
                                  ? Colors.grey[900]
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      IconBox(
                        iconData: Icons.hexagon_outlined,
                        selected: drawingMode.value == DrawingMode.polygon,
                        onTap: () => drawingMode.value = DrawingMode.polygon,
                        tooltip: 'Polygon',
                      ),
                      IconBox(
                        iconData: FontAwesomeIcons.square,
                        selected: drawingMode.value == DrawingMode.square,
                        onTap: () => drawingMode.value = DrawingMode.square,
                        tooltip: 'Square',
                      ),
                      IconBox(
                        iconData: FontAwesomeIcons.circle,
                        selected: drawingMode.value == DrawingMode.circle,
                        onTap: () => drawingMode.value = DrawingMode.circle,
                        tooltip: 'Circle',
                      ),
                      ColorSelector(selectedColor: selectedColor),
                      StrokeSelector(strokeSize: strokeSize),
                      const Divider(
                        color: Colors.black,
                        height: 10,
                      ),
                      IconBox(
                        iconData: FontAwesomeIcons.arrowRotateLeft,
                        selected: allSketches.value.isNotEmpty,
                        onTap: () {
                          if (allSketches.value.isNotEmpty) {
                            undoRedoStack.value.undo();
                          }
                        },
                        tooltip: 'Undo',
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: undoRedoStack.value.canRedo,
                        builder: (_, canRedo, __) {
                          return IconBox(
                            iconData: FontAwesomeIcons.arrowRotateRight,
                            selected: canRedo,
                            onTap: canRedo
                                ? () => undoRedoStack.value.redo()
                                : () {},
                            tooltip: 'Redo',
                          );
                        },
                      ),
                    ],
                  )),
            ],
          ));
    } else if (state is DrawingDetailStateError) {
      return Text('Error: ${state.errorMessage}');
    } else {
      return Container();
    }
  }

  // https://github.com/JohannesMilke/interactive_viewer_example
  void _fitToView() {
    final animationReset = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(controllerReset);

    animationReset.addListener(() {
      setState(() {
        controller.value = animationReset.value;
      });
    });
    controllerReset
      ..reset()
      ..forward();
  }
}

class ColorSelector extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final GlobalKey iconBoxKey = GlobalKey();

  ColorSelector({
    Key? key,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _showColorPalette(context),
        child: Container(
          key: iconBoxKey,
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: selectedColor.value,
            border: Border.all(color: Colors.blue, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ));
  }

  void _showColorPalette(BuildContext context) {
    final RenderBox renderBox =
        iconBoxKey.currentContext!.findRenderObject() as RenderBox;
    final iconBoxPosition = renderBox.localToGlobal(Offset.zero);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: iconBoxPosition.dx - 200,
        top: iconBoxPosition.dy,
        child: SizedBox(
          width: 200,
          child: ColorPalette(
            selectedColor: selectedColor,
            onColorSelected: (color) {
              selectedColor.value = color;
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class StrokeSelector extends StatefulWidget {
  final ValueNotifier<double> strokeSize;

  const StrokeSelector({
    Key? key,
    required this.strokeSize,
  }) : super(key: key);

  @override
  StrokeSelectorState createState() => StrokeSelectorState();
}

class StrokeSelectorState extends State<StrokeSelector> {
  @override
  Widget build(BuildContext context) {
    return IconBox(
        iconData: Icons.brush,
        selected: false,
        tooltip: 'Stroke Size',
        onTap: () => _showStrokeSizeSlider(context));
  }

  void _showStrokeSizeSlider(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final iconBoxPosition = renderBox.localToGlobal(Offset.zero);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
              left: iconBoxPosition.dx - 200,
              top: iconBoxPosition.dy,
              child: Material(
                child: ValueListenableBuilder<double>(
                    valueListenable: widget.strokeSize,
                    builder: (context, value, child) {
                      return Slider(
                        value: widget.strokeSize.value,
                        min: 2,
                        max: 25,
                        onChanged: (val) {
                          widget.strokeSize.value = val;
                        },
                        onChangeEnd: (val) {
                          widget.strokeSize.value = val;
                          overlayEntry.remove();
                        },
                      );
                    }),
              ),
            ));

    Overlay.of(context).insert(overlayEntry);
  }
}
