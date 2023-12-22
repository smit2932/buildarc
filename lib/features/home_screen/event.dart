import 'package:ardennes/models/projects/project_metadata.dart';

sealed class HomeScreenEvent {}

class InitEvent extends HomeScreenEvent {}

class FetchHomeScreenContentEvent extends HomeScreenEvent {
  final ProjectMetadata selectedProject;

  FetchHomeScreenContentEvent(this.selectedProject);
}
