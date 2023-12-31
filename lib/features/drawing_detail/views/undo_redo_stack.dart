import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:flutter/material.dart';

///A data structure for undoing and redoing sketches.
class UndoRedoStack {
  UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
    required this.onDeleteAnnotation,
    required this.onAddAnnotation,
  }) {
    _sketchCount = sketchesNotifier.value.list.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<Sketches> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;
  final Function(String) onDeleteAnnotation;
  final Function(Sketch) onAddAnnotation; // Add this line


  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.list.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.list.length;
    }
  }

  void undo() {
    final sketches = Sketches(
        List<Sketch>.from(sketchesNotifier.value.list), DateTime.now());
    if (sketches.list.isNotEmpty) {
      _sketchCount--;
      final sketch = sketches.list.removeLast();
      final sketchDocumentId = sketch.documentId;
      if (sketchDocumentId != null) {
        onDeleteAnnotation(sketchDocumentId);
      }
      _redoStack.add(sketch);
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = Sketches(
      [...sketchesNotifier.value.list, sketch],
      DateTime.now(),
    );
    onAddAnnotation(sketch); // Call the callback with the redone Sketch
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
