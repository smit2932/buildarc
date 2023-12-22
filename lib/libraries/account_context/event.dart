import 'package:ardennes/models/projects/project_metadata.dart';

sealed class AccountContextEvent {}

class InitEvent extends AccountContextEvent {}

class SwitchSelectedProject extends AccountContextEvent {
  final ProjectMetadata project;

  SwitchSelectedProject(this.project);
}
