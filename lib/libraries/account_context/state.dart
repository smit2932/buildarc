import '../../models/projects/project_metadata.dart';

class AccountContextState {
  AccountContextState init() {
    return AccountContextState();
  }

  AccountContextState clone() {
    return AccountContextState();
  }
}

class AccountContextLoadedState extends AccountContextState {
  final ProjectMetadata? selectedProject;
  final List<ProjectMetadata> projects;

  AccountContextLoadedState(
      {required this.projects, required this.selectedProject});
}

class AccountContextErrorState extends AccountContextState {
  final String errorMessage;

// TODO: error code
// 1: no projects setup
// 2: error fetching projects
// 3: error saving selected project
// 4: error loading selected project
// 5: error loading user data

  AccountContextErrorState(this.errorMessage);
}
