import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/account_context/state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc.dart';
import 'event.dart';
import 'recently_drawings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeScreenBloc(),
      child: Builder(builder: (context) => _HomeScreenContent()),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountContextBloc>().state;

    if (state is AccountContextLoadedState) {
      final selectedProject = state.selectedProject;
      if (selectedProject != null) {
        context
            .read<HomeScreenBloc>()
            .add(FetchHomeScreenContentEvent(selectedProject));
      }
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text("Welcome, ${FirebaseAuth.instance.currentUser?.displayName ?? ""}",
          style: Theme.of(context).textTheme.titleLarge),
      Text("Here's what's happening on your projects today.",
          style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 16),
      Card(
        elevation: 1,
        child: ListTile(
            leading: const Icon(Icons.sticky_note_2),
            title: const Text('Add Sheets'),
            onTap: () => context.go('/drawing-publish/file-upload')),
      ),
      const RecentlyViewedDrawings(),
    ]);
  }
}
