import 'package:dartz/dartz.dart';

class MessengerState {
  final String _handle; // My handle
  final Option<String> _friend; // Person I'm currently having a chat with

  MessengerState(this._handle, this._friend);

  // Copy "constructor" for partial updates
  MessengerState copy({String handle, Option<String> friend}) =>
      new MessengerState(handle ?? this._handle, friend ?? this._friend);

  String get handle => _handle;
  Option<String> get friend => _friend;
}
