abstract class DrawingDetailEvent {}

class LoadSheet extends DrawingDetailEvent {
  final String number;
  final String collection;
  final int versionId;
  final String projectId;

  LoadSheet(
      {required this.number,
      required this.collection,
      required this.versionId,
      required this.projectId});
}
