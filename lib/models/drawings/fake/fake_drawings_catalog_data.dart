import 'dart:math';

import 'package:ardennes/models/drawings/fake/fake_drawing_items_data.dart';
import 'package:ardennes/models/drawings/fake/fake_drawings_catalog_log.dart';
import 'package:ardennes/models/fake_helper/document_id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, dynamic> createVersion(int id, String name, int sheetsCount) {
  return {
    "id": id,
    "name": name,
    "issuance_date": Timestamp.now(),
    "created_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "sheets_count": sheetsCount,
  };
}

Map<String, dynamic> createCollection(
    String name, Map<String, Map<String, int>> versions) {
  return {
    "name": name,
    "versions": versions,
    "created_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "create_on": Timestamp.now()
  };
}

Map<String, dynamic> createDiscipline(
    String designator, String name, Map<String, Map<String, int>> versions) {
  return {
    "designator": designator,
    "name": name,
    "versions": versions,
  };
}

Map<String, dynamic> createTag(
    String name, Map<String, Map<String, int>> versions) {
  return {
    "name": name,
    "versions": versions,
  };
}

Map<String, dynamic> createPublishedLog(
    String sessionId,
    List<String> fileNames,
    String collection,
    String versionSet,
    int versionId,
    int sheetsCount,
    String status) {
  return {
    "session_id": sessionId,
    "file_names": fileNames,
    "collection": collection,
    "version_set": versionSet,
    "version_id": versionId,
    "issuance_date": Timestamp.now(),
    "sheets_count": sheetsCount,
    "published_on_date": Timestamp.now(),
    "published_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
    "status": status,
  };
}

// need to add activity logs, subcollections with sharding

final drawingsCatalog1 = <String, dynamic>{
  "project_id": "dkm87fh3fdh30j",
  "append_drawing_item_to_document": "iejbduwj2873ndu",
  "append_activity_log_to_document": "939jhfj2k00j4876",
  "versions": [
    createVersion(0, "Initial Set", 10),
    createVersion(1, "Version Two", 10),
  ],
  "collections": [
    createCollection("Story One", {
      "0": {"sheets_count": 1},
      "1": {"sheets_count": 1},
    }),
    createCollection("Zone Two", {
      "0": {"sheets_count": 7},
      "1": {"sheets_count": 7},
    }),
    createCollection("ungrouped", {
      "0": {"sheets_count": 3},
      "1": {"sheets_count": 3},
    }),
  ],
  "disciplines": [
    createDiscipline("A", "Architecture", {
      "0": {"sheets_count": 2},
      "1": {"sheets_count": 2},
    }),
    createDiscipline("B", "Geotechnical", {
      "0": {"sheets_count": 3},
      "1": {"sheets_count": 3},
    }),
    createDiscipline("C", "Civil", {
      "0": {"sheets_count": 5},
      "1": {"sheets_count": 6},
    }),
  ],
  "tags": [
    createTag("tag1", {
      "0": {"sheets_count": 2},
      "1": {"sheets_count": 2},
    }),
    createTag("tag2", {
      "0": {"sheets_count": 2},
      "1": {"sheets_count": 2},
    }),
  ],
  "published_logs": [
    createPublishedLog("72dk963hd", ["file1.pdf", "file1_1.pdf"],
        "Building One", "Version One", 0, 1, "Published"),
    createPublishedLog("kcj3i38f74hof", ["file2.pdf", "file2_2.pdf"],
        "Building Two", "Version One", 0, 7, "In Review"),
  ],
};

final drawingsCatalog2 = <String, dynamic>{
  "project_id": "d8j3h8d7h3d8h",
  "append_drawing_item_to_document": "jcn37594f736",
  "append_activity_log_to_document": "08hfhj3986tiudh",
  "versions": [
    createVersion(0, "Initial Set", 10),
    createVersion(1, "Version Two", 10),
  ],
  "collections": [
    createCollection("Story One", {
      "0": {"sheets_count": 1},
      "1": {"sheets_count": 1},
    }),
    createCollection("Zone Two", {
      "0": {"sheets_count": 7},
      "1": {"sheets_count": 7},
    }),
    createCollection("ungrouped", {
      "0": {"sheets_count": 3},
      "1": {"sheets_count": 3},
    }),
  ],
  "disciplines": [
    createDiscipline("A", "Architecture", {
      "0": {"sheets_count": 2},
      "1": {"sheets_count": 2},
    }),
    createDiscipline("B", "Geotechnical", {
      "0": {"sheets_count": 3},
      "1": {"sheets_count": 3},
    }),
    createDiscipline("C", "Civil", {
      "0": {"sheets_count": 5},
      "1": {"sheets_count": 6},
    }),
  ],
  "tags": [
    createTag("tag1", {
      "0": {"sheets_count": 2},
      "1": {"sheets_count": 2},
    }),
    createTag("tag2", {
      "0": {"sheets_count": 2},
      "1": {"sheets_count": 2},
    }),
  ],
  "published_logs": [
    createPublishedLog("83jfnh4i5763gj", ["file1.pdf", "file1_1.pdf"],
        "Story One", "Version One", 0, 1, "Published"),
    createPublishedLog("0jgfhj3idy2oifj", ["file2.pdf", "file2_1.pdf"],
        "Zone Two", "Version One", 0, 7, "In Review"),
  ],
};

void populateDrawingsCatalogNoorAcademy(List<dynamic> drawings) {
  final drawingsCatalog =
      FirebaseFirestore.instance.collection("drawings_catalog");
  final random = Random(getDeterministicRandomSeed(
      "drawings_catalog")); // Seeded random number generator
  var catalogs = [drawingsCatalog1, drawingsCatalog2];
  for (var catalog in catalogs) {
    var catalogDocumentId = generateDocumentId(20, random);
    drawingsCatalog.doc(catalogDocumentId).set(catalog);
    populateDrawingItemsFromDetailsOfNoorAcademy(catalogDocumentId, drawings);
    populateFakeDrawingsCatalogActivityLogs(catalogDocumentId);
  }
}