import 'package:ardennes/libraries/core_ui/canvas/drawing_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Sketch {
  final List<Offset> points;
  final Color color;
  final int size;
  final SketchType type;
  final bool filled;
  final int sides;

  Sketch({
    required this.points,
    this.color = Colors.black,
    this.type = SketchType.scribble,
    this.filled = true,
    this.sides = 3,
    required this.size,
  });

  factory Sketch.fromDrawingMode(
    Sketch sketch,
    DrawingMode drawingMode,
    bool filled,
  ) {
    return Sketch(
      points: sketch.points,
      color: sketch.color,
      size: sketch.size,
      filled: drawingMode == DrawingMode.line ||
              drawingMode == DrawingMode.pencil ||
              drawingMode == DrawingMode.eraser
          ? false
          : filled,
      sides: sketch.sides,
      type: () {
        switch (drawingMode) {
          case DrawingMode.eraser:
          case DrawingMode.pencil:
            return SketchType.scribble;
          case DrawingMode.line:
            return SketchType.line;
          case DrawingMode.square:
            return SketchType.square;
          case DrawingMode.circle:
            return SketchType.circle;
          case DrawingMode.polygon:
            return SketchType.polygon;
          default:
            return SketchType.scribble;
        }
      }(),
    );
  }

  static Map<String, dynamic> toFirestore(Sketch sketch, SetOptions? options) {
    List<Map> pointsMap =
        sketch.points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList();
    return {
      'points': pointsMap,
      'color': sketch.color.toHex(),
      'size': sketch.size,
      'filled': sketch.filled,
      'type': sketch.type.toRegularString(),
      'sides': sketch.sides,
    };
  }

  factory Sketch.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    List<Offset> points =
        (data?['points'] as List).map((e) => Offset(e['dx'], e['dy'])).toList();
    return Sketch(
      points: points,
      color: (data?['color'] as String).toColor(),
      size: data?['size'],
      filled: data?['filled'],
      type: SketchType.values[data?['type']],
      sides: data?['sides'],
    );
  }


  static Map<String, dynamic> toFirestoreOptimized(
      Sketch sketch, SetOptions? options) {
    List<Map> pointsMap;
    if (sketch.type != SketchType.scribble) {
      pointsMap = [
        {'dx': sketch.points.first.dx, 'dy': sketch.points.first.dy},
        {'dx': sketch.points.last.dx, 'dy': sketch.points.last.dy},
      ];
    } else {
      pointsMap = sketch.points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList();
    }

    return {
      'points': pointsMap,
      'color': sketch.color.toHex(),
      'size': sketch.size,
      'type': sketch.type.index,
      'filled': sketch.filled,
      'sides': sketch.sides,
    };
  }
}


enum SketchType { scribble, line, square, circle, polygon }

extension SketchTypeX on SketchType {
  String toRegularString() => toString().split('.')[1];
}

extension SketchTypeExtension on String {
  SketchType toSketchTypeEnum() =>
      SketchType.values.firstWhere((e) => e.toString() == 'SketchType.$this');
}

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    } else {
      return Colors.black;
    }
  }


}

extension ColorExtensionX on Color {
  String toHex() => '#${value.toRadixString(16).substring(2, 8)}';
}
