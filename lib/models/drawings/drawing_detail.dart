import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingVersion {
  final Map<String, String> files;
  final String createdByUserId;
  final Timestamp issuanceDate;
  final String publishSessionId;
  final String publishStatus;
  final String versionSet;

  DrawingVersion({
    required this.files,
    required this.createdByUserId,
    required this.issuanceDate,
    required this.publishSessionId,
    required this.publishStatus,
    required this.versionSet,
  });

  factory DrawingVersion.fromMap(Map<String, dynamic> map) {
    return DrawingVersion(
      files: Map<String, String>.from(map['files']),
      createdByUserId: map['published_by_user_id'],
      issuanceDate: map['issuance_date'],
      publishSessionId: map['publish_session_id'],
      publishStatus: map['status'],
      versionSet: map['version_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'files': files,
      'created_by_user_id': createdByUserId,
      'issuance_date': issuanceDate,
      'publish_session_id': publishSessionId,
      'publish_status': publishStatus,
      'version_set': versionSet,
    };
  }
}

class DrawingDetail {
  final String collection;
  final String number;
  final String projectId;
  final String discipline;
  final List<String> tags;
  final Map<int, DrawingVersion> versions;

  DrawingDetail({
    required this.collection,
    required this.number,
    required this.projectId,
    required this.discipline,
    required this.tags,
    required this.versions,
  });

  factory DrawingDetail.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return DrawingDetail(
      collection: data?['collection'],
      number: data?['number'],
      projectId: data?['project'],
      discipline: data?['discipline'],
      tags: List<String>.from(data?['tags']),
      versions: (data?['versions'] as Map<String, dynamic>).map((key, value) =>
          MapEntry(int.parse(key),
              DrawingVersion.fromMap(value as Map<String, dynamic>)))
      ,
    );
  }

  static Map<String, dynamic> toFirestore(
      DrawingDetail drawingDetail, SetOptions? options) {
    return {
      'collection': drawingDetail.collection,
      'number': drawingDetail.number,
      'project_id': drawingDetail.projectId,
      'discipline': drawingDetail.discipline,
      'tags': drawingDetail.tags,
      'versions': drawingDetail.versions,
    };
  }
}
