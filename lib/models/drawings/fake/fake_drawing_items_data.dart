import 'dart:math';

import 'package:ardennes/models/fake_helper/document_id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, dynamic> createDrawingItem(
    String collection,
    String discipline,
    List<String> tags,
    Map<String, String> images,
    String title,
    int versionId) {
  return {
    "collection": collection,
    "discipline": discipline,
    "images": images,
    "tags": tags,
    "title": title,
    "version_id": versionId,
  };
}

Map<String, dynamic> createDrawingItems(List<Map<String, dynamic>> items) {
  return {
    "items": items,
  };
}

final drawingItems1 = createDrawingItems([
  createDrawingItem(
    "Zone One",
    "Architectural",
    ["tag1", "tag2"],
    {
      "sd_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sd_image.jpg",
      "thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-thumbnail_image.jpg",
      "micro_thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-micro_thumbnail_image.jpg",
      "sheet_number_clip":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sheet_number_clip.jpg",
    },
    "Drawing Title",
    0,
  ),
  createDrawingItem(
    "Zone One",
    "Geotechnical",
    ["tag2"],
    {
      "sd_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sd_image_2.jpg",
      "micro_thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-micro_thumbnail_image_2.jpg",
      "thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-thumbnail_image_2.jpg",
      "sheet_number_clip":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sheet_number_clip_2.jpg",
    },
    "Drawing Title 2",
    0,
  ),
]);

final drawingItems2 = createDrawingItems([
  createDrawingItem(
    "Building One",
    "Civil",
    ["tag1"],
    {
      "sd_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sd_image.jpg",
      "micro_thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-micro_thumbnail_image.jpg",
      "thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-thumbnail_image.jpg",
      "sheet_number_clip":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sheet_number_clip.jpg",
    },
    "Drawing Title Building",
    0,
  ),
  createDrawingItem(
    "Zone One",
    "Geotechnical",
    ["tag4"],
    {
      "sd_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sd_image_3.jpg",
      "micro_thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-micro_thumbnail_image_3.jpg",
      "thumbnail_image":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-thumbnail_image_3.jpg",
      "sheet_number_clip":
          "https://firebasestorage.googleapis.com/v0/b/ardennes-sheet_number_clip_3.jpg",
    },
    "Drawing Title 2",
    0,
  ),
]);

void populateDrawingItemsInCatalog(catalogId) {
  final random = Random(getDeterministicRandomSeed(
      "$catalogId/drawing_items")); // Seeded random number generator

  final drawingItems = FirebaseFirestore.instance
      .collection('drawings_catalog')
      .doc(catalogId)
      .collection('drawing_items');

  for (var items in [drawingItems1, drawingItems2]) {
    final documentId =
        generateDocumentId(20, random); // Generate a repeatable random ID
    drawingItems.doc(documentId).set(items);
  }
}

Future<void> populateDrawingItemsFromDetailsOfNoorAcademy(
    String catalogId, List<dynamic> drawings) async {
  final random = Random(getDeterministicRandomSeed(
      "$catalogId/drawings_catalog_drawing_items")); // Seeded random number generator

  const numberOfItemsPerDocument = 10;

  final drawingItems = FirebaseFirestore.instance
      .collection('drawings_catalog')
      .doc(catalogId)
      .collection('drawing_items');

  var lastDocumentId = "";
  for (var i = 0; i < drawings.length; i += numberOfItemsPerDocument) {
    final end = (i + numberOfItemsPerDocument < drawings.length)
        ? i + numberOfItemsPerDocument
        : drawings.length;
    final sublist = drawings.sublist(i, end);

    final items = sublist.map((drawing) {
      return createDrawingItem(
        drawing["collection"],
        drawing["discipline"],
        drawing["tags"],
        drawing["versions"]["0"]["files"],
        drawing["number"],
        0,
      );
    }).toList();

    final documentId = generateDocumentId(20, random);
    lastDocumentId = documentId;
    drawingItems.doc(documentId).set({"items": items});
  }

  await updateDrawingCatalog(catalogId, lastDocumentId);
}

Future<void> updateDrawingCatalog(String catalogId, String lastDocumentId) async {
  final drawingsCatalog = FirebaseFirestore.instance.collection("drawings_catalog");
  await drawingsCatalog.doc(catalogId).update({
    'append_drawing_item_to_document': lastDocumentId,
  });
}
