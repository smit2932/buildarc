import 'dart:convert';

import 'package:ardennes/models/accounts/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ardennes/models/projects/project_metadata.dart';
import 'state.dart';
import 'event.dart';

class AccountContextBloc
    extends Bloc<AccountContextEvent, AccountContextState> {
  List<ProjectMetadata> projects = [];

  AccountContextBloc() : super(AccountContextState().init()) {
    on<InitEvent>(_fetchProjects);
    on<SwitchSelectedProject>(_updateSelectedProject);
  }

  void _updateSelectedProject(
      SwitchSelectedProject event, Emitter<AccountContextState> emit) async {
    _saveSelectedProject(event.project);
    emit(AccountContextLoadedState(
        projects: projects, selectedProject: event.project));
  }

  void _fetchProjects(
      InitEvent event, Emitter<AccountContextState> emit) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return emit(AccountContextErrorState("No Projects Setup"));
    }

    String userId = currentUser.uid;
    DocumentReference<UserData> userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .withConverter<UserData>(
          fromFirestore: (snapshot, options) =>
              UserData.fromFirestore(snapshot, options),
          toFirestore: (userData, options) =>
              UserData.toFirestore(userData, options),
        );
    UserData? userData;
    try {
      DocumentSnapshot<UserData> docSnapshot = await userDoc.get();
      userData = docSnapshot.data();
    } catch (e) {
      debugPrint(e.toString());
      emit(AccountContextErrorState("Error fetching user data"));
    }

    if (userData == null) {
      // TODO: Handle no user data
      emit(AccountContextErrorState("No user data"));
      return;
    }
    projects = userData.projects ?? [];
    if (projects.isEmpty) {
      // TODO: Handle no projects setup
      emit(AccountContextErrorState("No Projects Setup"));
      return;
    }
    final savedFirstProject = await loadSelectedProject();
    if (savedFirstProject != null && projects.contains(savedFirstProject)) {
      emit(AccountContextLoadedState(
          projects: projects, selectedProject: savedFirstProject));
    } else {
      emit(AccountContextLoadedState(
          projects: projects, selectedProject: projects.first));
      _saveSelectedProject(projects.first);
    }
  }

  Future<void> _saveSelectedProject(ProjectMetadata project) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String projectString = jsonEncode(project.toJson());
    await prefs.setString('selectedProject', projectString);
  }

  Future<ProjectMetadata?> loadSelectedProject() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? projectString = prefs.getString('selectedProject');
    if (projectString != null) {
      Map<String, dynamic> projectJson = jsonDecode(projectString);
      return ProjectMetadata.fromJson(projectJson);
    } else {
      return null;
    }
  }
}
