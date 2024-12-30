import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:ardennes/models/drawings/drawing_detail.dart';
import 'package:ardennes/models/projects/project_metadata.dart';

abstract class DrawingDetailEvent {}

class LoadSheet extends DrawingDetailEvent {
  final String number;
  final String collection;
  final int versionId;
  final String projectId;

  LoadSheet({required this.number,
    required this.collection,
    required this.versionId,
    required this.projectId});
}

class AddAnnotation extends DrawingDetailEvent {
  final Sketch annotation;

  AddAnnotation(this.annotation);
}

class DeleteAnnotation extends DrawingDetailEvent {
  final String annotationId;

  DeleteAnnotation(this.annotationId);
}

class UpdateAnnotation extends DrawingDetailEvent {
  final Sketch annotation;

  UpdateAnnotation(this.annotation);
}

class AddRecentDrawingEvent extends DrawingDetailEvent {
  final ProjectMetadata selectedProject;
  final DrawingDetail drawingDetail;

  AddRecentDrawingEvent(
    this.selectedProject,
    this.drawingDetail,
  );
}
