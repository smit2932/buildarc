import 'package:ardennes/features/home_screen/state.dart';
import 'package:ardennes/libraries/core_ui/image_downloading/image_firebase.dart';
import 'package:ardennes/libraries/core_ui/shimmer/bar_shimmer.dart';
import 'package:ardennes/libraries/extensions/scoped.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc.dart';

class RecentlyViewedDrawings extends StatelessWidget {
  const RecentlyViewedDrawings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        child: Column(children: [
          ListTile(
            leading: Text("Recently viewed sheets",
                style: Theme.of(context).textTheme.titleLarge),
            trailing: TextButton(
              onPressed: () {},
              child:
                  Text("See all", style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 0),
          ),
          SizedBox(
              height: 240,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
                      builder: (context, state) {
                    if (state is FetchedHomeScreenContentState) {
                      return ListView.separated(
                        padding: const EdgeInsets.only(
                            top: 16.0, bottom: 16.0, right: 16.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.recentlyViewedDrawingTiles.length,
                        itemBuilder: (BuildContext context, int index) =>
                            state.recentlyViewedDrawingTiles[index].let((tile) {
                          return _RecentlyViewedDrawingTile(
                              title: tile.title,
                              subtitle: tile.subtitle,
                              drawingThumbnailUrl: tile.drawingThumbnailUrl);
                        }),
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: 16.0),
                      );
                    } else if (state is FetchingHomeScreenContentState) {
                      return const BarShimmer(
                        baseColor: Colors.grey,
                        highlightColor: Colors.white,
                        height: 20.0,
                      );
                    } else if (state is HomeScreenFetchErrorState) {
                      return Text(state.errorMessage);
                    } else {
                      return Container();
                    }
                  })))
        ]));
  }
}

class _RecentlyViewedDrawingTile extends StatelessWidget {
  const _RecentlyViewedDrawingTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.drawingThumbnailUrl,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String drawingThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          context.go(
            Uri(
              path: '/drawings/sheet',
              queryParameters: {
                'number': title,
                'collection': subtitle,
                'versionId': "0",
              },
            ).toString(),
          );
        },
        child: Container(
          width: 135,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(children: [
                Expanded(
                  flex: 4,
                  // child: Image.asset(drawingThumbnailUrl),
                  child: ImageFromFirebase(imageUrl: drawingThumbnailUrl),
                ),
                const Divider(),
                Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ])),
              ])),
        ));
  }
}
