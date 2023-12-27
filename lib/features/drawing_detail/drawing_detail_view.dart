import 'package:ardennes/features/drawing_detail/drawing_detail_event.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_event.dart';
import 'package:ardennes/features/drawings_catalog/drawings_catalog_state.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/core_ui/image_downloading/image_firebase.dart';
import 'package:ardennes/libraries/core_ui/window_size/window_size_calculator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class SheetWidget extends StatefulWidget {
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
    final state = widget.state;
    if (state is DrawingDetailStateLoading) {
      return const CircularProgressIndicator();
    } else if (state is DrawingDetailStateLoaded) {
      return Container(
        color: Colors.grey[300],
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 16.0,
          boundaryMargin: const EdgeInsets.all(20.0),
          transformationController: controller,
          child: Center(
            child: ImageFromFirebase(
              imageUrl: state
                  .drawingDetail.versions[widget.versionId]!.files["hd_image"]!,
            ),
          ),
        ),
      );
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

class SideNavigation extends StatelessWidget {
  const SideNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      NavigationRail(
        selectedIndex: 0,
        onDestinationSelected: (index) {},
        labelType: NavigationRailLabelType.selected,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Sheets'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.sticky_note_2_outlined),
            selectedIcon: Icon(Icons.sticky_note_2),
            label: Text('Punch'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.photo_album_outlined),
            selectedIcon: Icon(Icons.photo_album),
            label: Text('Photos'),
          ),
        ],
      ),
      const VerticalDivider(thickness: 1, width: 1),
      const SizedBox(
          width: 300, // Set the width as needed
          child: DrawingsCatalog()),
    ]);
  }
}

class DrawingsCatalog extends StatelessWidget {
  final ScrollController? scrollController;
  final VoidCallback? onLoadSheet;

  const DrawingsCatalog({Key? key, this.scrollController, this.onLoadSheet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingsCatalogBloc, DrawingsCatalogState>(
      builder: (context, state) {
        if (state is FetchedDrawingsCatalogState) {
          final items = state.displayedItems;
          return ListView.builder(
            controller: scrollController ?? ScrollController(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: ImageFromFirebase(imageUrl: item.smallThumbnailUrl),
                // Display the smallThumbnail
                title: Text(item.title),
                // Display the title
                subtitle: Text(item.discipline),
                // Display the discipline
                onTap: () {
                  context.read<DrawingDetailBloc>().add(
                        LoadSheet(
                            number: item.title,
                            collection: item.collection,
                            versionId: item.versionId,
                            projectId: state.drawingsCatalog.projectId),
                      );
                  onLoadSheet?.call();
                },
              );
            },
          );
        } else {
          // Handle other states or return an empty Container
          return Container();
        }
      },
    );
  }
}

class PullUpWindowSizeNavigation extends StatelessWidget {
  const PullUpWindowSizeNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final windowSize = WindowSizeCalculator.getWindowSize(context);
    switch (windowSize) {
      case WindowSize.medium:
      case WindowSize.expanded:
        return PullUpNavigation(
          left: 20,
          width: MediaQuery.of(context).size.width * 0.40,
          initialChildSize: 0.4,
          minChildSize: 0.2,
        );
      case WindowSize.xcompact:
      case WindowSize.compact:
        return PullUpNavigation(
          left: 0,
          width: MediaQuery.of(context).size.width,
          initialChildSize: 0.3,
          minChildSize: 0.1,
        );
    }
  }
}

class PullUpNavigation extends StatelessWidget {
  final double left;
  final double width;
  final double initialChildSize;
  final double minChildSize;

  const PullUpNavigation({
    Key? key,
    required this.left,
    required this.width,
    required this.initialChildSize,
    required this.minChildSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: DraggableScrollableActuator(
          child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: 0.9,
        snap: true,
        snapSizes: const [1 / 3],
        snapAnimationDuration: const Duration(milliseconds: 300),
        builder: (BuildContext context, ScrollController scrollController) {
          const handleBar = HandleBar();
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: Container(
              color: Colors.blue[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  handleBar,
                  Expanded(
                      child: DrawingsCatalog(
                    scrollController: scrollController,
                    onLoadSheet: () {
                      handleBar.resetScrollPosition(context);
                    },
                  )),
                ],
              ),
            ),
          );
        },
      )),
    );
  }
}

class HandleBar extends StatelessWidget {
  const HandleBar({Key? key}) : super(key: key);

  // function to reset the scroll position
  void resetScrollPosition(BuildContext context) {
    DraggableScrollableActuator.reset(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DraggableScrollableActuator.reset(context);
      },
      child: Container(
        height: 20,
        width: 40,
        color: Colors.transparent,
        child: Center(
          child: Container(
            height: 5.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: const BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
