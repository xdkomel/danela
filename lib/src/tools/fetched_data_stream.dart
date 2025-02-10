import 'dart:async';

import 'fetched_data.dart';

class FetchedDataStream<T> {
  FetchedData<T> _value = const NoData();
  final _streamController = StreamController<FetchedData<T>>.broadcast();
  FetchedDataStream() {
    _streamController.add(const NoData());
  }

  FetchedData<T> get value => _value;

  Stream<FetchedData<T>> get stream => _streamController.stream;

  void _emit(FetchedData<T> data) {
    _value = data;
    _streamController.add(data);
  }

  void emitLoading() => _emit(const LoadingData());

  void emitSuccess(T data) => _emit(SuccessData(data));

  void emitError(T error) => _emit(ErrorData(error));

  void close() {
    _streamController.close();
    _value = const NoData();
  }
}
