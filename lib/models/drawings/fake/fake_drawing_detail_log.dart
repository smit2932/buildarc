import 'dart:math';

import 'package:ardennes/models/fake_helper/document_id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final drawingDetailActivityLogs1 = [
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-4 (Version 1) to BR-404 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-5 (Version 1) to BR-405 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-6 (Version 1) to BR-406 in Ungrouped sheets."
  }
];

final drawingDetailActivityLogs2 = [
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-7 (Version 1) to BR-407 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-8 (Version 1) to BR-408 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-9 (Version 1) to BR-409 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "content":
    "Good Faith renumbered sheet BR-10 (Version 1) to BR-410 in Ungrouped sheets."
  }
];

void populateFakeDrawingDetailActivityLogs(String drawingDocumentId) {
  var random =
  Random(getDeterministicRandomSeed("drawingsActivityLogs"));
  var drawings = FirebaseFirestore.instance.collection('drawings');

  var docActivityLogs =
  drawings.doc(drawingDocumentId).collection('activity_logs');
  for (var log in drawingDetailActivityLogs1) {
    docActivityLogs.doc(generateDocumentId(20, random)).set(log);
  }
}
