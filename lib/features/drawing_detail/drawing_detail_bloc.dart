import 'package:ardennes/libraries/drawing/image_provider.dart';
import 'package:ardennes/models/drawings/drawing_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'drawing_detail_event.dart';
import 'drawing_detail_state.dart';

@injectable
class DrawingDetailBloc extends Bloc<DrawingDetailEvent, DrawingDetailState> {
  final UIImageProvider uiImageProvider;

  DrawingDetailBloc({required this.uiImageProvider})
      : super(DrawingDetailState().init()) {
    on<LoadSheet>(_init);
  }

  void _init(LoadSheet event, Emitter<DrawingDetailState> emit) async {
    emit(DrawingDetailStateLoading());

    Query<DrawingDetail> drawingDetailQuery = FirebaseFirestore.instance
        .collection('drawings')
        .where('project', isEqualTo: event.projectId)
        .where('number', isEqualTo: event.number)
        .where('collection', isEqualTo: event.collection)
        .withConverter(
          fromFirestore: DrawingDetail.fromFirestore,
          toFirestore: DrawingDetail.toFirestore,
        );

    try {
      final drawingDetailSnapshot = await drawingDetailQuery.get();
      final drawingDetail = drawingDetailSnapshot.docs.firstOrNull?.data();
      if (drawingDetail != null) {
        final image = await uiImageProvider.getImage(
          drawingDetail.versions[event.versionId]!.files["hd_image"]!,
        );
        emit(DrawingDetailStateLoaded(
          drawingDetail: drawingDetail,
          image: image,
        ));
      } else {
        emit(DrawingDetailStateError(errorMessage: 'No drawing found'));
      }
    } catch (e) {
      emit(DrawingDetailStateError(errorMessage: e.toString()));
    }
  }
}
