import 'package:dartz/dartz.dart';

class MessengerState {
  final String _handle;
  final Option<String> _friend;

  MessengerState(this._handle, this._friend);

  // Copy "constructor" for partial updates
  MessengerState copy({String handle, String friend}) =>
      new MessengerState(handle ?? this._handle, friend ?? this._friend);

  String get handle => _handle;

  // // Lenses for accessing and updating
  // static final handle = lensS<MessengerState, String>((state) => state._handle,
  //     (state, newHandle) => state.copy(handle: newHandle));
}
