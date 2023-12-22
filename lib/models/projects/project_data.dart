import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectData {
  final String? id;
  final String? companyId;
  final String? name;
  final String? number;
  final String? address;
  final String? stage;
  final bool? isActive;

  ProjectData({
    this.id,
    this.companyId,
    this.name,
    this.number,
    this.isActive,
    this.address,
    this.stage,
  });

  factory ProjectData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ProjectData(
      id: snapshot.id,
      companyId: data?['company_id'],
      name: data?['name'],
      isActive: data?['is_active'],
      address: data?['address'],
      number: data?['number'],
      stage: data?['stage'],
    );
  }

  static Map<String, Object?> toFirestore(
      Object? projectData, SetOptions? options) {
    if (projectData is ProjectData) {
      return {
        if (projectData.companyId != null) "company_id": projectData.companyId,
        if (projectData.name != null) "name": projectData.name,
        if (projectData.isActive != null) "is_active": projectData.isActive,
        if (projectData.address != null) "address": projectData.address,
        if (projectData.number != null) "number": projectData.number,
        if (projectData.stage != null) "stage": projectData.stage,
      };
    } else {
      throw ArgumentError("projectData is not an instance of ProjectData");
    }
  }
}
