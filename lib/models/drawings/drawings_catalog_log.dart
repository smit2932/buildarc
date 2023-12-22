import 'package:cloud_firestore/cloud_firestore.dart';

/// This class logs activities done to the the drawings ot the project level.
/// E.g. add, edit, delete collections
/// add, edit, delete, and restore version sets
/// add, edit, delete discipline
/// add, edit, delete tags
class DrawingsCatalogActivityLog {
  final DateTime timestamp;
  final String activity;
  final int versionId;
  final String actionByUserId;
  final String content;
  
  DrawingsCatalogActivityLog({
    required this.timestamp,
    required this.activity,
    required this.versionId,
    required this.actionByUserId,
    required this.content,
  });
  
  factory DrawingsCatalogActivityLog.fromJson(Map<String, dynamic> map) {
    return DrawingsCatalogActivityLog(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      activity: map['activity'],
      versionId: map['version_id'],
      actionByUserId: map['action_by_user_id'],
      content: map['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'activity': activity,
      'version_id': versionId,
      'action_by_user_id': actionByUserId,
      'content': content,
    };
  }
}