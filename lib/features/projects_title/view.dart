import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/account_context/event.dart';
import 'package:ardennes/libraries/account_context/state.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsTitle extends StatefulWidget {
  const ProjectsTitle({Key? key}) : super(key: key);

  @override
  State<ProjectsTitle> createState() => _ProjectsTitleState();
}

class _ProjectsTitleState extends State<ProjectsTitle> {
  List<ProjectMetadata> projects = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountContextBloc, AccountContextState>(
        builder: (context, state) {
      if (state is AccountContextLoadedState) {
        final projects = state.projects;
        final selectedProject = state.selectedProject;
        if (projects.isNotEmpty && selectedProject != null) {
          return _ProjectsDropDownList(
              selectedProject: selectedProject, projects: state.projects);
        } else {
          // TODO: Show the setup screen for no projects
          return Container();
        }
      } else if (state is AccountContextErrorState) {
        // TODO: Show the error screen
        return const Text("Error fetching projects");
      } else {
        return const Text("Loading...");
      }
    });
  }
}

class _ProjectsDropDownList extends StatefulWidget {
  const _ProjectsDropDownList(
      {Key? key, required this.selectedProject, required this.projects})
      : super(key: key);

  final ProjectMetadata selectedProject;
  final List<ProjectMetadata> projects;

  @override
  _ProjectsDropDownListState createState() => _ProjectsDropDownListState();
}

class _ProjectsDropDownListState extends State<_ProjectsDropDownList> {
  late ProjectMetadata selectedProject;

  @override
  void initState() {
    super.initState();
    selectedProject = widget.selectedProject;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: DropdownButton<ProjectMetadata>(
          value: selectedProject,
          onChanged: (ProjectMetadata? newProject) {
            if (newProject != null) {
              context
                  .read<AccountContextBloc>()
                  .add(SwitchSelectedProject(newProject));
              setState(() {
                selectedProject = newProject;
              });
            }
          },
          items: (widget.projects).map(
            (ProjectMetadata project) {
              return DropdownMenuItem<ProjectMetadata>(
                value: project,
                child: Text(
                  project.name ?? "Project",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            },
          ).toList(),
          underline: Container(),
        ));
  }
}
