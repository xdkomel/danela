import 'dart:async';

class AsyncValue<T> {
  T _value;
  final _streamController = StreamController<T>.broadcast();
  AsyncValue(this._value);

  T get value => _value;

  Stream<T> get stream => _streamController.stream;

  void emit(T newVal) {
    _value = newVal;
    _streamController.add(newVal);
  }

  void close() {
    _streamController.close();
  }
}
