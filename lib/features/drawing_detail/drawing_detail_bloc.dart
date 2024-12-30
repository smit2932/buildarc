import 'package:ardennes/libraries/core_ui/canvas/sketch.dart';
import 'package:ardennes/libraries/drawing/image_provider.dart';
import 'package:ardennes/models/drawings/drawing_detail.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'drawing_detail_event.dart';
import 'drawing_detail_state.dart';

@injectable
class DrawingDetailBloc extends Bloc<DrawingDetailEvent, DrawingDetailState> {
  final UIImageProvider uiImageProvider;
  String? currentDrawingDocumentId;

  DrawingDetailBloc({required this.uiImageProvider}) : super(DrawingDetailState().init()) {
    on<LoadSheet>(_loadSheet);
    on<AddAnnotation>(_addAnnotation);
    on<DeleteAnnotation>(_deleteAnnotation);
    on<UpdateAnnotation>(_updateAnnotation);
    on<AddRecentDrawingEvent>(_addRecentDrawing);
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

        if (currentDrawingDocumentId != null) {
          final annotationsQuery = FirebaseFirestore.instance
              .collection('drawings')
              .doc(currentDrawingDocumentId)
              .collection('annotations')
              .withConverter(
                fromFirestore: Sketch.fromFirestore,
                toFirestore: Sketch.toFirestore,
              );

          // How to use Bloc with streams and concurrency
          // Or, how to migrate your blocs and cubits to Bloc >=7.2.0
          // https://verygood.ventures/blog/how-to-use-bloc-with-streams-and-concurrency
          await emit.forEach(
            annotationsQuery.snapshots(),
            onData: (annotationsSnapshot) {
              final List<Sketch> annotations =
                  annotationsSnapshot.docs.map((doc) => doc.data()).toList();

              annotations.sort((a, b) => a.updateTime.compareTo(b.updateTime));
              return DrawingDetailStateLoaded(
                drawingDetail: drawingDetail,
                image: image,
                annotations: Sketches(annotations, DateTime.now()),
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

  void _deleteAnnotation(
      DeleteAnnotation event, Emitter<DrawingDetailState> emit) async {
    final documentId = currentDrawingDocumentId;
    if (documentId == null) {
      emit(DrawingDetailStateError(errorMessage: 'No drawing found'));
    } else {
      await FirebaseFirestore.instance
          .collection('drawings')
          .doc(documentId)
          .collection('annotations')
          .doc(event.annotationId)
          .delete();
    }
  }

  void _updateAnnotation(
      UpdateAnnotation event, Emitter<DrawingDetailState> emit) async {
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
          .doc(event.annotation.documentId)
          .update(annotationMap);
    }
  }

  Future<void> _addRecentDrawing(AddRecentDrawingEvent event, Emitter<DrawingDetailState> emit) async {
    // User
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return emit(DrawingDetailStateError(errorMessage: "User doesn't exist"));
    }

    String userId = currentUser.uid;

    // Adding recent logic
    FirebaseFirestore.instance.useFirestoreEmulator('192.168.1.18', 8080);
    Query<HomeScreenData> getRecentDrawingQuery = FirebaseFirestore.instance
        .collection('home_screens')
        .where('user_id', isEqualTo: userId)
        .where('project_id', isEqualTo: event.selectedProject.id)
        .withConverter(
          fromFirestore: HomeScreenData.fromFirestore,
          toFirestore: HomeScreenData.toFirestore,
        );

    try {
      QuerySnapshot<HomeScreenData> querySnapshot = await getRecentDrawingQuery.get();
      HomeScreenData? homeScreenData = querySnapshot.docs.firstOrNull?.data();

      if (homeScreenData == null) {
        // Add data
        final Map<String, Object?> recentData = HomeScreenData.toFirestore(HomeScreenData.fromDrawingDetail(event.drawingDetail), null);
        await FirebaseFirestore.instance.collection('home_screens').add(recentData);
      } else {
        // Update existing entry
        await FirebaseFirestore.instance
            .collection('home_screens')
            .doc(querySnapshot.docs.first.id)
            .update(HomeScreenData.toFirestore(HomeScreenData.fromDrawingDetail(event.drawingDetail), null));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
