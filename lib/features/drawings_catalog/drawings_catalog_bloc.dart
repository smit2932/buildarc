import 'package:ardennes/models/drawings/drawing_item.dart';
import 'package:ardennes/models/drawings/drawings_catalog_data.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawings_catalog_event.dart';
import 'drawings_catalog_state.dart';

class DrawingsCatalogBloc
    extends Bloc<DrawingsCatalogEvent, DrawingsCatalogState> {
  DrawingsCatalogUIState savedUiState = DrawingsCatalogUIState();
  ProjectMetadata? savedSelectedProject;

  DrawingsCatalogBloc() : super(DrawingsCatalogState().init()) {
    on<InitEvent>(_init);
    on<FetchDrawingsCatalogEvent>(_fetchDrawingCatalog);
    on<UpdateSelectedCollectionEvent>(_updateSelectedCollection);
    on<UpdateSelectedDisciplineEvent>(_updateSelectedDiscipline);
    on<UpdateSelectedTagEvent>(_updateSelectedTag);
    on<UpdateSelectedVersionEvent>(_updateSelectedVersion);
  }

  void _init(InitEvent event, Emitter<DrawingsCatalogState> emit) async {
    emit(state.clone());
  }

  void _updateSelectedVersion(
      UpdateSelectedVersionEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedVersion = event.selectedVersion;
    _updateSelected(emit);
  }

  void _updateSelectedCollection(
      UpdateSelectedCollectionEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedCollection = event.selectedCollection;
    _updateSelected(emit);
  }

  void _updateSelectedDiscipline(
      UpdateSelectedDisciplineEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedDiscipline = event.selectedDiscipline;
    _updateSelected(emit);
  }

  void _updateSelectedTag(
      UpdateSelectedTagEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedTag = event.selectedTag;
    _updateSelected(emit);
  }

  void _updateSelected(Emitter<DrawingsCatalogState> emit) {
    final state = this.state;
    if (state is FetchedDrawingsCatalogState) {
      final filteredItems = state.drawingsCatalog.drawingItems.where((item) {
        return (savedUiState.selectedVersion == null ||
                item.versionId == savedUiState.selectedVersion?.id) &&
            (savedUiState.selectedCollection == null ||
                item.collection == savedUiState.selectedCollection?.name) &&
            (savedUiState.selectedDiscipline == null ||
                item.discipline == savedUiState.selectedDiscipline?.name) &&
            (savedUiState.selectedTag == null ||
                item.tags.contains(savedUiState.selectedTag?.name));
      }).toList();
      emit(FetchedDrawingsCatalogState(
          drawingsCatalog: state.drawingsCatalog,
          displayedItems: filteredItems,
          uiState: savedUiState));
    }
  }

  void _fetchDrawingCatalog(FetchDrawingsCatalogEvent event,
      Emitter<DrawingsCatalogState> emit) async {
    if (savedSelectedProject == event.selectedProject) return;
    savedUiState = DrawingsCatalogUIState();
    savedSelectedProject = event.selectedProject;

    emit(FetchingDrawingsCatalogState());

    Query<DrawingsCatalogData> drawingsCatalogQuery = FirebaseFirestore.instance
        .collection('drawings_catalog')
        .where('project_id', isEqualTo: event.selectedProject.id)
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
        emit(FetchedDrawingsCatalogState(
          drawingsCatalog: drawingsCatalog,
          displayedItems: drawingsCatalog.drawingItems,
          uiState: savedUiState,
        ));
      } else {
        emit(DrawingsCatalogFetchErrorState("Project id doesn't exist"));
      }
    } catch (e) {
      emit(DrawingsCatalogFetchErrorState(e.toString()));
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
