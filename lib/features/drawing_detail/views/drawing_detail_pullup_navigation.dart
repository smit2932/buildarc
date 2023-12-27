import 'package:ardennes/features/drawing_detail/views/drawing_detail_list_view.dart';
import 'package:ardennes/libraries/core_ui/window_size/window_size_calculator.dart';
import 'package:flutter/material.dart';

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
