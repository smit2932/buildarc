import 'package:ardennes/features/projects_title/view.dart';
import 'package:ardennes/libraries/core_ui/window_size/window_size_calculator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = WindowSizeCalculator.getWindowSize(context);
    return _buildPage(context, windowSize);
  }

  Widget _buildPage(BuildContext context, WindowSize windowSize) {
    switch (windowSize) {
      case WindowSize.medium:
      case WindowSize.expanded:
        return _NonCompactLayout(navigationShell: widget.navigationShell);
      case WindowSize.xcompact:
      case WindowSize.compact:
        return _CompactLayout(navigationShell: widget.navigationShell);
    }
  }
}

class _CompactLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _CompactLayout({Key? key, required this.navigationShell})
      : super(key: key);

  @override
  State<_CompactLayout> createState() => _CompactLayoutState();
}

class _CompactLayoutState extends State<_CompactLayout>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const ProjectsTitle(),
      ),
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            activeIcon: Icon(Icons.sticky_note_2),
            label: 'Drawings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            activeIcon: Icon(Icons.photo_album),
            label: 'Photos',
          ),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _NonCompactLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _NonCompactLayout({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);

  @override
  State<_NonCompactLayout> createState() => _NonCompactLayoutState();
}

class _NonCompactLayoutState extends State<_NonCompactLayout>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const ProjectsTitle(),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sticky_note_2_outlined),
                selectedIcon: Icon(Icons.sticky_note_2),
                label: Text('Drawings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.photo_album_outlined),
                selectedIcon: Icon(Icons.photo_album),
                label: Text('Photos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.more_horiz_outlined),
                selectedIcon: Icon(Icons.more_horiz),
                label: Text('More'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }
}
