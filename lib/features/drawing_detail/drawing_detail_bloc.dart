import 'dart:async';

import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
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
  String? currentDrawingDocumentId;

  DrawingDetailBloc({required this.uiImageProvider})
      : super(DrawingDetailState().init()) {
    on<LoadSheet>(_loadSheet);
    on<AddAnnotation>(_addAnnotation);
  }

  void _loadSheet(LoadSheet event, Emitter<DrawingDetailState> emit) async {
    emit(DrawingDetailStateLoading());

    final Query<DrawingDetail> drawingDetailQuery = FirebaseFirestore.instance
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
        currentDrawingDocumentId = drawingDetailSnapshot.docs.firstOrNull?.id;
        final image = await uiImageProvider.getImage(
          drawingDetail.versions[event.versionId]!.files["hd_image"]!,
        );
        final loadedState = DrawingDetailStateLoaded(
          drawingDetail: drawingDetail,
          image: image,
          annotations: [],
        );
        emit(loadedState);

        if (currentDrawingDocumentId != null) {
          final annotationsQuery = FirebaseFirestore.instance
              .collection('drawings')
              .doc(currentDrawingDocumentId)
              .collection('annotations')
              .withConverter(
                fromFirestore: Sketch.fromFirestore,
                toFirestore: Sketch.toFirestore,
              );
          emit.forEach(
            annotationsQuery.snapshots(),
            onData: (annotationsSnapshot) {
              final List<Sketch> annotations =
                  annotationsSnapshot.docs.map((doc) => doc.data()).toList();

              return DrawingDetailStateLoaded(
                drawingDetail: loadedState.drawingDetail,
                image: loadedState.image,
                annotations: annotations,
              );
            },
          );
        }
      } else {
        emit(DrawingDetailStateError(errorMessage: 'No drawing found'));
      }
    } catch (e) {
      emit(DrawingDetailStateError(errorMessage: e.toString()));
    }
  }

  void _loadAnnotations(
      Emitter<DrawingDetailState> emit, DrawingDetailStateLoaded loadedState) {}

  void _addAnnotation(
      AddAnnotation event, Emitter<DrawingDetailState> emit) async {
    final annotation = event.annotation;
    final annotationMap = Sketch.toFirestoreOptimized(annotation, null);

    final documentId = currentDrawingDocumentId;
    if (documentId == null) {
      emit(DrawingDetailStateError(errorMessage: 'No drawing found'));
    } else {
      await FirebaseFirestore.instance
          .collection('drawings')
          .doc(documentId)
          .collection('annotations')
          .add(annotationMap);
    }
  }
}
