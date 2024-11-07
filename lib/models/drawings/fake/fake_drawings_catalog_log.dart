import 'dart:math';

import 'package:ardennes/models/fake_helper/document_id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final drawingsCatalogActivityLogs = [
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
    "content":
        "Good Faith renumbered sheet BR-4 (Version 1) to BR-404 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
    "content":
        "Good Faith renumbered sheet BR-5 (Version 1) to BR-405 in Ungrouped sheets."
  },
  {
    "timestamp": Timestamp.now(),
    "activity": "renumber",
    "version_id": 1,
    "action_by_user_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
    "content":
        "Good Faith renumbered sheet BR-6 (Version 1) to BR-406 in Ungrouped sheets."
  }
];

void populateDrawingsCatalogActivityLogs(drawingsCatalogId) {
  var random =
      Random(getDeterministicRandomSeed("drawingsCatalogActivityLogs"));
  var drawingsCatalog = FirebaseFirestore.instance.collection('drawings_catalog');

  var docActivityLogs =
      drawingsCatalog.doc(drawingsCatalogId).collection('activity_logs');
  for (var log in drawingsCatalogActivityLogs) {
    docActivityLogs.doc(generateDocumentId(20, random)).set(log);
  }
}
