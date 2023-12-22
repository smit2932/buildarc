import 'package:ardennes/models/drawings/drawing_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DrawingItemsLoader {
  Future<List<DrawingItem>> load(String projectId);
}

class FirebaseDrawingItemsLoader implements DrawingItemsLoader {
  static final FirebaseDrawingItemsLoader _singleton =
      FirebaseDrawingItemsLoader._internal();

  factory FirebaseDrawingItemsLoader() {
    return _singleton;
  }

  FirebaseDrawingItemsLoader._internal();

  @override
  Future<List<DrawingItem>> load(String projectId) async {
    final drawingItems = <DrawingItem>[];

    final drawingItemsRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('drawing_items');

    final drawingItemsQuery = await drawingItemsRef.get();

    for (final drawingItemDoc in drawingItemsQuery.docs) {
      final drawingItem = DrawingItem.fromMap(drawingItemDoc.data());
      drawingItems.add(drawingItem);
    }

    return drawingItems;
  }
}
