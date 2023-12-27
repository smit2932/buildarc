import 'dart:ui';

import 'package:ardennes/features/drawing_detail/views/drawing_detail_pullup_navigation.dart';
import 'package:ardennes/features/drawing_detail/views/drawing_detail_side_navigation.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_event.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/core_ui/canvas/drawing_canvas.dart';
import 'package:ardennes/libraries/core_ui/canvas/drawing_mode.dart';
import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:ardennes/libraries/core_ui/image_downloading/image_firebase.dart';
import 'package:ardennes/libraries/core_ui/window_size/window_size_calculator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
                sheetKey.currentState?.fitToView();
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
    final backgroundImage = useState<Image?>(null);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final state = widget.state;
    if (state is DrawingDetailStateLoading) {
      return const CircularProgressIndicator();
    } else if (state is DrawingDetailStateLoaded) {
      return Container(
          color: Colors.grey[300],
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.1,
                maxScale: 16.0,
                boundaryMargin: const EdgeInsets.all(20.0),
                transformationController: controller,
                child: Center(
                  child: ImageFromFirebase(
                    imageUrl: state.drawingDetail.versions[widget.versionId]!
                        .files["hd_image"]!,
                  ),
                ),
              ),

              Container(
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
                  polygonSides: polygonSides,
                  backgroundImage: backgroundImage,
                ),
              ),
              Positioned(
                  right: 200, // Adjust as needed
                  top: 10, // Adjust as needed
                  child: Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                          });
                        },
                        child: const Icon(Icons.add),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          // Handle button press
                        },
                        child: const Icon(Icons.remove),
                      ),
                      // Add more FloatingActionButton widgets as needed
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
  void fitToView() {
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
