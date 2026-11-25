import 'package:flutter_bloc/flutter_bloc.dart';

/// Whether a password field hides its text. `true` = hidden.
class VisibilityCubit extends Cubit<bool> {
  VisibilityCubit({required bool hidden}) : super(hidden);

  void toggle() => emit(!state);
}
