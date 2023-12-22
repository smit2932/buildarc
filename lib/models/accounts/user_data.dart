import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String? id;
  final String? companyId;
  final List<ProjectMetadata>? projects;

  UserData({
    this.id,
    this.companyId,
    this.projects,
  });

  factory UserData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserData(
      id: snapshot.id,
      companyId: data?['company_id'],
      projects: data?['projects'] is Iterable
          ? List.from(data?['projects'])
              .map((projectMap) =>
                  ProjectMetadata.fromMap(projectMap as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  static Map<String, Object?> toFirestore(
      Object? userData, SetOptions? options) {
    if (userData is UserData) {
      return {
        if (userData.companyId != null) "company_id": userData.companyId,
        if (userData.projects != null)
          "projects": userData.projects
              ?.map((project) => {
                    "project_id": project.id,
                    "project_name": project.name,
                  })
              .toList(),
      };
    } else {
      throw ArgumentError("userData is not an instance of UserData");
    }
  }
}
