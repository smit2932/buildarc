import 'package:ardennes/models/screens/home_screen_data.dart';

class HomeScreenState {
  HomeScreenState init() {
    return HomeScreenState();
  }

  HomeScreenState clone() {
    return HomeScreenState();
  }
}

class FetchingHomeScreenContentState extends HomeScreenState {
  @override
  FetchingHomeScreenContentState clone() {
    return FetchingHomeScreenContentState();
  }
}

class FetchedHomeScreenContentState extends HomeScreenState {
  final List<RecentlyViewedDrawingTile> recentlyViewedDrawingTiles;

  FetchedHomeScreenContentState({
    required this.recentlyViewedDrawingTiles,
  });

  @override
  FetchedHomeScreenContentState clone() {
    return FetchedHomeScreenContentState(
      recentlyViewedDrawingTiles: recentlyViewedDrawingTiles,
    );
  }
}

class HomeScreenFetchErrorState extends HomeScreenState {
  final String errorMessage;

  HomeScreenFetchErrorState(this.errorMessage);

  @override
  HomeScreenFetchErrorState clone() {
    return HomeScreenFetchErrorState(errorMessage);
  }
}
