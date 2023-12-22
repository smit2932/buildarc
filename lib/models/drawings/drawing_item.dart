import 'package:cloud_firestore/cloud_firestore.dart';

/// One DrawingItem only tracks one version of a drawing.
/// If another drawing of the same number and collection
/// is added for a different version, then a new DrawingItem.
class DrawingItem {
  final String title;
  final String microThumbnailUrl;
  final String thumbnailUrl;
  final String sdUrl;
  final String sheetNumberClip;
  final String collection;
  final int versionId;
  final String discipline;
  final List<String> tags;

  DrawingItem(
      {
      required this.title,
      required this.microThumbnailUrl,
      required this.thumbnailUrl,
      required this.sdUrl,
      required this.sheetNumberClip,
      required this.collection,
      required this.versionId,
      required this.discipline,
      required this.tags});

  factory DrawingItem.fromMap(Map<String, dynamic> map) {
    return DrawingItem(
      title: map['title'],
      microThumbnailUrl: map['images']['micro_thumbnail_image'],
      thumbnailUrl: map['images']['thumbnail_image'],
      sdUrl: map['images']['sd_image'],
      sheetNumberClip: map['images']['sheet_number_clip'],
      collection: map['collection'],
      versionId: map['version_id'],
      discipline: map['discipline'],
      tags: List<String>.from(map['tags']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "images": {
        'micro_thumbnail_url': microThumbnailUrl,
        'thumbnail_url': thumbnailUrl,
        'sd_url': sdUrl,
        'sheet_number_clip': sheetNumberClip,
      },
      'collection': collection,
      'version_id': versionId,
      'discipline': discipline,
      'tags': tags,
    };
  }
}

class DrawingItemsData {
  final List<DrawingItem> items;

  DrawingItemsData({
    required this.items,
  });

  factory DrawingItemsData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return DrawingItemsData(
      items: data?['items'] is Iterable
          ? List.from(data?['items'])
              .map((item) => DrawingItem.fromMap(item))
              .toList()
          : [],
    );
  }

  static Map<String, dynamic> toFirestore(
      DrawingItemsData drawingItemsData, SetOptions? options) {
    return {
      'items': drawingItemsData.items.map((item) => item.toMap()).toList(),
    };
  }
}
