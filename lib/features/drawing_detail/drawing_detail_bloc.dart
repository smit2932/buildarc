import 'package:ardennes/models/drawings/drawing_detail.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'drawing_detail_event.dart';
import 'drawing_detail_state.dart';

class DrawingDetailBloc extends Bloc<DrawingDetailEvent, DrawingDetailState> {
  DrawingDetailBloc() : super(DrawingDetailState().init()) {
    on<InitEvent>(_init);
  }

  void _init(InitEvent event, Emitter<DrawingDetailState> emit) async {
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
        emit(DrawingDetailStateLoaded(drawingDetail: drawingDetail));
      } else {
        emit(DrawingDetailStateError(errorMessage: 'No drawing found'));
      }
    } catch (e) {
      emit(DrawingDetailStateError(errorMessage: e.toString()));
    }
  }
}
