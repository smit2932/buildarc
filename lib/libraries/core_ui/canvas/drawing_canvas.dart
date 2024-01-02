import 'dart:math' as math;
import 'dart:ui';

import 'package:ardennes/libraries/core_ui/canvas/color_palette.dart';
import 'package:ardennes/libraries/core_ui/canvas/drawing_mode.dart';
import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingCanvas extends HookWidget {
  final double height;
  final double width;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<Image?> backgroundImage;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<Sketches> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<bool> filled;
  final ValueNotifier<bool> isScaling;
  final ValueNotifier<bool> isEditing;
  final Function(Sketch) onAddAnnotation;
  final Function(Sketch) onUpdateAnnotation;

  final Color kCanvasColor = const Color(0xfff2f3f7);

  const DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.isScaling,
    required this.isEditing,
    required this.polygonSides,
    required this.backgroundImage,
    required this.onAddAnnotation,
    required this.onUpdateAnnotation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Stack(
        children: [
          buildAllSketches(context),
          buildCurrentPath(context),
        ],
      ),
    );
  }

  Future<void> onPointerDown(
      PointerDownEvent details, BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    if (isEditing.value) {
      final selectedAnnotation = getSelectedAnnotation(offset);
      if (selectedAnnotation != null) {
        Color? selectedColor = await _showColorPalette(context);
        if (selectedColor != null) {
          final newSketch = Sketch(
            points: List<Offset>.from(selectedAnnotation.points),
            color: selectedColor,
            size: selectedAnnotation.size,
            type: selectedAnnotation.type,
            filled: selectedAnnotation.filled,
            sides: selectedAnnotation.sides,
            createTime: selectedAnnotation.createTime,
            updateTime: DateTime.now(),
            documentId: selectedAnnotation.documentId,
          );

          final index = allSketches.value.list.indexOf(selectedAnnotation);
          if (index != -1) {
            allSketches.value.list[index] = newSketch;
            onUpdateAnnotation(newSketch);
          }
        }
      }
      return;
    }
    // Check if a scaling gesture is in progress
    const int delayToConfirmScaling = 100;
    Future.delayed(const Duration(milliseconds: delayToConfirmScaling), () {
      if (isScaling.value) return;
      currentSketch.value = Sketch.fromDrawingMode(
        Sketch(
          points: [offset],
          size: drawingMode.value == DrawingMode.eraser
              ? eraserSize.value.toInt()
              : strokeSize.value.toInt(),
          color: drawingMode.value == DrawingMode.eraser
              ? kCanvasColor
              : selectedColor.value,
          sides: polygonSides.value,
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
        ),
        drawingMode.value,
        filled.value,
      );
    });
  }

  Future<Color?> _showColorPalette(BuildContext context) async {
    return await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ColorPalette(
            onColorSelected: (color) {
              Navigator.of(context).pop(color);
            },
          ),
        );
      },
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    var points = <Offset>[];
    // unfortunately isScaling only becomes true after the first onPointerDown/onPointerMove
    final currentSketchPoints = currentSketch.value?.points ?? [];
    if (!isScaling.value && currentSketchPoints.isNotEmpty) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.position);
      points = List<Offset>.from(currentSketch.value?.points ?? [])
        ..add(offset);
    }

    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value.toInt()
            : strokeSize.value.toInt(),
        color: drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : selectedColor.value,
        sides: polygonSides.value,
        createTime: currentSketch.value?.createTime ?? DateTime.now(),
        updateTime: DateTime.now(),
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    if (!isScaling.value && currentSketch.value!.points.isNotEmpty) {
      allSketches.value = Sketches(
          List<Sketch>.from(allSketches.value.list)..add(currentSketch.value!),
          DateTime.now());
      onAddAnnotation(currentSketch.value!);
    }
    cleanUpCurrentSketch();
  }

  void cleanUpCurrentSketch() {
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value.toInt()
            : strokeSize.value.toInt(),
        color: drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : selectedColor.value,
        sides: polygonSides.value,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      drawingMode.value,
      filled.value,
    );
  }

  Sketch? getSelectedAnnotation(Offset point) {
    // Get all sketches whose bounding box contains the point
    final candidates = allSketches.value.list.where((sketch) {
      final points = sketch.points;
      final minX = points.map((point) => point.dx).reduce(math.min);
      final maxX = points.map((point) => point.dx).reduce(math.max);
      final minY = points.map((point) => point.dy).reduce(math.min);
      final maxY = points.map((point) => point.dy).reduce(math.max);

      return point.dx >= minX &&
          point.dx <= maxX &&
          point.dy >= minY &&
          point.dy <= maxY;
    }).toList();

    // If there are no candidates, return null
    if (candidates.isEmpty) {
      return null;
    }

    // Sort the candidates by updateTime in descending order and return the first one
    candidates.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return candidates.first;
  }

  Widget buildAllSketches(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ValueListenableBuilder<Sketches>(
        valueListenable: allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: canvasGlobalKey,
            child: Container(
              height: height,
              width: width,
              color: kCanvasColor,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches.list,
                  backgroundImage: backgroundImage.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp: onPointerUp,
      // onPointerPanZoomStart: (_) => isScaling.value = true,
      // onPointerPanZoomEnd: (_) => isScaling.value = false,
      child: ValueListenableBuilder(
        valueListenable: currentSketch,
        builder: (context, sketch, child) {
          return RepaintBoundary(
            child: SizedBox(
              height: height,
              width: width,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketch == null ? [] : [sketch],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;
  final Image? backgroundImage;

  const SketchPainter({
    Key? key,
    this.backgroundImage,
    required this.sketches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      final double originalWidth = backgroundImage!.width.toDouble();
      final double originalHeight = backgroundImage!.height.toDouble();
      final double originalAspectRatio = originalWidth / originalHeight;

      double targetWidth = size.width;
      double targetHeight = size.height;

      if (originalAspectRatio > 1) {
        // If the original image is wider than it is tall
        targetHeight = targetWidth / originalAspectRatio;
        if (targetHeight > size.height) {
          // If the scaled image is still too tall
          targetHeight = size.height;
          targetWidth = targetHeight * originalAspectRatio;
        }
      } else {
        // If the original image is taller than it is wide
        targetWidth = targetHeight * originalAspectRatio;
        if (targetWidth > size.width) {
          // If the scaled image is still too wide
          targetWidth = size.width;
          targetHeight = targetWidth / originalAspectRatio;
        }
      }
      double verticalOffset = (size.height - targetHeight) / 2;
      double horizontalOffset = (size.width - targetWidth) / 2;

      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(0, 0, originalWidth, originalHeight),
        Rect.fromLTWH(
            horizontalOffset, verticalOffset, targetWidth, targetHeight),
        Paint(),
      );
    }
    for (Sketch sketch in sketches) {
      final points = sketch.points;
      if (points.isEmpty) return;

      final path = Path();

      path.moveTo(points[0].dx, points[0].dy);
      if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      for (int i = 1; i < points.length - 1; ++i) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round;

      if (!sketch.filled) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = sketch.size.toDouble();
      }

      // define first and last points for convenience
      Offset firstPoint = sketch.points.first;
      Offset lastPoint = sketch.points.last;

      // create rect to use rectangle and circle
      Rect rect = Rect.fromPoints(firstPoint, lastPoint);

      // Calculate center point from the first and last points
      Offset centerPoint = (firstPoint / 2) + (lastPoint / 2);

      // Calculate path's radius from the first and last points
      double radius = (firstPoint - lastPoint).distance / 2;

      if (sketch.type == SketchType.scribble) {
        canvas.drawPath(path, paint);
      } else if (sketch.type == SketchType.square) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      } else if (sketch.type == SketchType.line) {
        canvas.drawLine(firstPoint, lastPoint, paint);
      } else if (sketch.type == SketchType.circle) {
        canvas.drawOval(rect, paint);
        // Uncomment this line if you need a PERFECT CIRCLE
        // canvas.drawCircle(centerPoint, radius , paint);
      } else if (sketch.type == SketchType.polygon) {
        Path polygonPath = Path();
        int sides = sketch.sides;
        var angle = (math.pi * 2) / sides;

        double radian = 0.0;

        Offset startPoint =
            Offset(radius * math.cos(radian), radius * math.sin(radian));

        polygonPath.moveTo(
          startPoint.dx + centerPoint.dx,
          startPoint.dy + centerPoint.dy,
        );
        for (int i = 1; i <= sides; i++) {
          double x = radius * math.cos(radian + angle * i) + centerPoint.dx;
          double y = radius * math.sin(radian + angle * i) + centerPoint.dy;
          polygonPath.lineTo(x, y);
        }
        polygonPath.close();
        canvas.drawPath(polygonPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}
