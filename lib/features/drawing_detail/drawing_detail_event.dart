abstract class DrawingDetailEvent {}

class InitEvent extends DrawingDetailEvent {
  final String number;
  final String collection;
  final int versionId;
  final String projectId;

  InitEvent(
      {required this.number,
      required this.collection,
      required this.versionId,
      required this.projectId});
}
