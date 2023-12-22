
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_files_event.dart';
import 'add_files_state.dart';

class AddFilesBloc extends Bloc<AddFilesEvent, AddFilesState> {
  AddFilesBloc() : super(AddFilesState().init()) {
    on<InitEvent>(_init);
  }

  void _init(InitEvent event, Emitter<AddFilesState> emit) async {
    emit(state.clone());
  }
}
