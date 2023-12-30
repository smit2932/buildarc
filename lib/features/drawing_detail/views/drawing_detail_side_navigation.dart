
import 'package:ardennes/features/drawing_detail/views/drawing_detail_list_view.dart';
import 'package:flutter/material.dart';

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
