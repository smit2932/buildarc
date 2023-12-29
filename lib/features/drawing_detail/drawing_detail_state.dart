import 'dart:ui';

import 'package:ardennes/models/drawings/drawing_detail.dart';

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

  DrawingDetailStateLoaded({required this.drawingDetail, this.image});

  @override
  DrawingDetailStateLoaded clone() {
    return DrawingDetailStateLoaded(drawingDetail: drawingDetail);
  }
}

class DrawingDetailStateError extends DrawingDetailState {
  final String errorMessage;

  DrawingDetailStateError({required this.errorMessage});

  @override
  DrawingDetailStateError clone() {
    return DrawingDetailStateError(errorMessage: errorMessage);
  }
}
