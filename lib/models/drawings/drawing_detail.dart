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
      createdByUserId: map['created_by_user_id'],
      issuanceDate: map['issuance_date'],
      publishSessionId: map['publish_session_id'],
      publishStatus: map['publish_status'],
      versionSet: map['version_set'],
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

  factory DrawingDetail.fromMap(Map<String, dynamic> map) {
    return DrawingDetail(
      collection: map['collection'],
      number: map['number'],
      projectId: map['project_id'],
      discipline: map['discipline'],
      tags: List<String>.from(map['tags']),
      versions: Map<int, DrawingVersion>.from(map['versions']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collection': collection,
      'number': number,
      'project_id': projectId,
      'discipline': discipline,
      'tags': tags,
      'versions': versions,
    };
  }
}
