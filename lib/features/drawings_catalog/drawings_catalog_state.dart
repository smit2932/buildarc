import 'package:ardennes/models/drawings/drawing_item.dart';
import 'package:ardennes/models/drawings/drawings_catalog_data.dart';

class DrawingsCatalogUIState {
  DrawingVersion? selectedVersion;
  DrawingCollection? selectedCollection;
  DrawingDiscipline? selectedDiscipline;
  DrawingTag? selectedTag;

  DrawingsCatalogUIState({
    this.selectedVersion,
    this.selectedCollection,
    this.selectedDiscipline,
    this.selectedTag,
  });
}

class DrawingsCatalogState {
  DrawingsCatalogState init() {
    return DrawingsCatalogState();
  }

  DrawingsCatalogState clone() {
    return DrawingsCatalogState();
  }
}

class FetchingDrawingsCatalogState extends DrawingsCatalogState {
  @override
  FetchingDrawingsCatalogState clone() {
    return FetchingDrawingsCatalogState();
  }
}

class FetchedDrawingsCatalogState extends DrawingsCatalogState {
  final DrawingsCatalogData drawingsCatalog;
  final List<DrawingItem> displayedItems;
  final DrawingsCatalogUIState uiState;

  FetchedDrawingsCatalogState({
    required this.drawingsCatalog,
    required this.displayedItems,
    required this.uiState,
  });

  @override
  FetchedDrawingsCatalogState clone() {
    return FetchedDrawingsCatalogState(
      drawingsCatalog: drawingsCatalog,
      displayedItems: displayedItems,
      uiState: uiState,
    );
  }
}

class DrawingsCatalogFetchErrorState extends DrawingsCatalogState {
  final String errorMessage;

  DrawingsCatalogFetchErrorState(this.errorMessage);

  @override
  DrawingsCatalogFetchErrorState clone() {
    return DrawingsCatalogFetchErrorState(errorMessage);
  }
}
