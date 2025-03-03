import 'dart:async';

import 'fetched_data.dart';

class FetchedDataStream<T> {
  FetchedData<T> _value = NoData<T>();
  final _streamController = StreamController<FetchedData<T>>.broadcast();
  FetchedDataStream() {
    _streamController.add(NoData<T>());
  }

  FetchedData<T> get value => _value;

  Stream<FetchedData<T>> get stream => _streamController.stream;

  void _emit(FetchedData<T> data) {
    _value = data;
    _streamController.add(data);
  }

  void emitLoading() => _emit(LoadingData<T>());

  void emitSuccess(T data) => _emit(SuccessData(data));

  void emitError(T error) => _emit(ErrorData(error));

  void close() {
    _streamController.close();
    _value = NoData<T>();
  }
}
