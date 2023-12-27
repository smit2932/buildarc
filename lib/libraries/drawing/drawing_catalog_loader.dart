import 'package:ardennes/models/drawings/drawing_item.dart';
import 'package:ardennes/models/drawings/drawings_catalog_data.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class DrawingCatalogService {
  ProjectMetadata? savedSelectedProject;

  DrawingCatalogService({@factoryParam this.savedSelectedProject});

  Future<DrawingsCatalogData?> fetchDrawingCatalog(
      ProjectMetadata selectedProject) async {
    savedSelectedProject = selectedProject;

    Query<DrawingsCatalogData> drawingsCatalogQuery = FirebaseFirestore.instance
        .collection('drawings_catalog')
        .where('project_id', isEqualTo: selectedProject.id)
        .withConverter(
          fromFirestore: DrawingsCatalogData.fromFirestore,
          toFirestore: DrawingsCatalogData.toFirestore,
        );

    try {
      QuerySnapshot<DrawingsCatalogData> querySnapshot =
          await drawingsCatalogQuery.get();
      QueryDocumentSnapshot<DrawingsCatalogData>? snapshot =
          querySnapshot.docs.firstOrNull;
      DrawingsCatalogData? drawingsCatalog = snapshot?.data();
      if (snapshot != null && drawingsCatalog != null) {
        drawingsCatalog.drawingItems = await _fetchDrawingItems(snapshot.id);
        return drawingsCatalog;
      } else {
        throw Exception("Project id doesn't exist");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<DrawingItem>> _fetchDrawingItems(String catalogDocumentId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('drawings_catalog')
        .doc(catalogDocumentId)
        .get()
        .then((value) {
      return value.reference
          .collection('drawing_items')
          .withConverter(
            fromFirestore: DrawingItemsData.fromFirestore,
            toFirestore: DrawingItemsData.toFirestore,
          )
          .get();
    });

    return querySnapshot.docs
        .map((doc) => doc.data())
        .expand((data) => data.items)
        .toList()
      ..sort((a, b) {
        var splitA = a.title.split('-');
        var splitB = b.title.split('-');

        var compareLetter = splitA[0].compareTo(splitB[0]);
        if (compareLetter != 0) {
          return compareLetter;
        } else {
          int numberA = int.parse(splitA[1]);
          int numberB = int.parse(splitB[1]);
          return numberA.compareTo(numberB);
        }
      });
  }
}
