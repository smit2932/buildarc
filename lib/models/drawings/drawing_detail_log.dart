import 'package:cloud_firestore/cloud_firestore.dart';
/// It records log at the sheet level
/// E.g. add sheet from project,
/// add sheet to project
/// add tag, change version set, change discipline, change collection
/// delete sheet, export sheet, generate link etc.
class DrawingDetailActivityLog {
  final DateTime timestamp;
  final String activity;
  final int versionId;
  final String actionByUserId;
  final String content;

  DrawingDetailActivityLog({
    required this.timestamp,
    required this.activity,
    required this.versionId,
    required this.actionByUserId,
    required this.content,
  });

  factory DrawingDetailActivityLog.fromJson(Map<String, dynamic> map) {
    return DrawingDetailActivityLog(
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