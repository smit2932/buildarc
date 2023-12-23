import 'package:ardennes/libraries/core_ui/image_downloading/image_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_detail_bloc.dart';
import 'drawing_detail_event.dart';
import 'drawing_detail_state.dart';

class DrawingDetailScreen extends StatefulWidget {
  final String number;
  final String collection;
  final String projectId;
  final int versionId;

  const DrawingDetailScreen(
      {super.key,
      required this.number,
      required this.collection,
      required this.projectId,
      required this.versionId});

  @override
  State<StatefulWidget> createState() => DrawingDetailScreenState();
}

class DrawingDetailScreenState extends State<DrawingDetailScreen>
    with TickerProviderStateMixin {
  final controller = TransformationController();
  late AnimationController controllerReset;

  @override
  void initState() {
    super.initState();
    controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => DrawingDetailBloc()
        ..add(InitEvent(
            number: widget.number,
            collection: widget.collection,
            versionId: widget.versionId,
            projectId: widget.projectId)),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: reset,
          ),
        ],
        title: const Text('Drawing Detail'),
      ),
      body: BlocBuilder<DrawingDetailBloc, DrawingDetailState>(
        builder: (context, state) {
          if (state is DrawingDetailStateLoading) {
            return const CircularProgressIndicator();
          } else if (state is DrawingDetailStateLoaded) {
            return Container(
                color: Colors.grey[300],
                // Set your desired background color here
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 16.0,
                  boundaryMargin: const EdgeInsets.all(20.0),
                  transformationController: controller,
                  child: Center(
                    child: ImageFromFirebase(
                      imageUrl: state.drawingDetail.versions[widget.versionId]!
                          .files["hd_image"]!,
                    ),
                  ),
                ));
          } else if (state is DrawingDetailStateError) {
            return Text('Error: ${state.errorMessage}');
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void reset() {
    final animationReset = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(controllerReset);

    animationReset.addListener(() {
      setState(() {
        controller.value = animationReset.value;
      });
    });
    controllerReset
      ..reset()
      ..forward();
  }
}
