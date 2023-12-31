import 'dart:ui';

import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:ardennes/models/drawings/drawing_detail.dart';
import 'package:flutter/foundation.dart';

class DrawingDetailState {
  DrawingDetailState init() {
    return DrawingDetailState();
  }

  DrawingDetailState clone() {
    return DrawingDetailState();
  }
}

class DrawingDetailStateLoading extends DrawingDetailState {
  @override
  DrawingDetailStateLoading clone() {
    return DrawingDetailStateLoading();
  }
}

class DrawingDetailStateLoaded extends DrawingDetailState {
  final DrawingDetail drawingDetail;
  final Image? image;
  final Sketches annotations;

  DrawingDetailStateLoaded(
      {required this.drawingDetail, this.image, required this.annotations});

  @override
  DrawingDetailStateLoaded clone() {
    return DrawingDetailStateLoaded(
        drawingDetail: drawingDetail, annotations: annotations);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingDetailStateLoaded &&
          runtimeType == other.runtimeType &&
          drawingDetail == other.drawingDetail &&
          image == other.image &&
          other.annotations.updateTime == annotations.updateTime &&
          listEquals(other.annotations.list, annotations.list);

  @override
  int get hashCode =>
      drawingDetail.hashCode ^ image.hashCode ^ annotations.hashCode;
}

class DrawingDetailStateError extends DrawingDetailState {
  final String errorMessage;

  DrawingDetailStateError({required this.errorMessage});

  @override
  DrawingDetailStateError clone() {
    return DrawingDetailStateError(errorMessage: errorMessage);
  }
}
