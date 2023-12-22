import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_files_bloc.dart';
import 'add_files_event.dart';

class AddFilesScreen extends StatelessWidget {
  const AddFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AddFilesBloc()..add(InitEvent()),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {

    return const Text('Add_files');
  }
}
