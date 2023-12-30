import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ColorPalette extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPalette({
    Key? key,
    required this.onColorSelected,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.black,
      Colors.white,
      ...Colors.primaries,
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: [
        for (Color color in colors)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                selectedColor.value = color;
                onColorSelected(color);
              },
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: selectedColor.value == color
                        ? Colors.blue
                        : Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
