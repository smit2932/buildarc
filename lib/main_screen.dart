import 'package:ardennes/features/drawings_catalog/drawings_catalog_view.dart';
import 'package:ardennes/features/home_screen/view.dart';
import 'package:ardennes/features/projects_title/view.dart';
import 'package:ardennes/libraries/core_ui/window_size/window_size_calculator.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget Function()> _contentScreenBuilders = [
    () => const HomeScreen(),
    () => const DrawingsCatalogScreen(),
    () => const Text('Photos'),
    () => const Text('More'),
  ];
  final List<Widget> _contentScreens = [];
  final List<bool> _builtIndices = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _contentScreenBuilders.length; i++) {
      _contentScreens.add(SizedBox.fromSize(size: Size.zero));
      _builtIndices.add(false);
    }
    _onTap(_selectedIndex);
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (!_builtIndices[index]) {
        _contentScreens[index] = _contentScreenBuilders[index]();
        _builtIndices[index] = true;
      }
    });
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
        return _NonCompactLayout(
          contentScreens: _contentScreens,
          selectedIndex: _selectedIndex,
          onTap: _onTap,
        );
      case WindowSize.xcompact:
      case WindowSize.compact:
        return _CompactLayout(
          contentScreens: _contentScreens,
          selectedIndex: _selectedIndex,
          onTap: _onTap,
        );
    }
  }
}

class _CompactLayout extends StatefulWidget {
  final List<Widget> contentScreens;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const _CompactLayout(
      {Key? key,
      required this.contentScreens,
      required this.selectedIndex,
      required this.onTap})
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
      body: IndexedStack(
        index: widget.selectedIndex,
        children: widget.contentScreens,
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
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
      ], currentIndex: widget.selectedIndex, onTap: widget.onTap),
    );
  }
}

class _NonCompactLayout extends StatefulWidget {
  final List<Widget> contentScreens;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const _NonCompactLayout(
      {Key? key,
      required this.contentScreens,
      required this.selectedIndex,
      this.onTap})
      : super(key: key);

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
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onTap,
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
          Expanded(
            child: IndexedStack(
              index: widget.selectedIndex,
              children: widget.contentScreens,
            ),
          ),
        ],
      ),
    );
  }
}
