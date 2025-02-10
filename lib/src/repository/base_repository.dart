import 'dart:async';

import 'errors/repository_not_initialized.dart';

import '../gateway/gateway.dart';
import '../request.dart';
import '../tools/fetched_data.dart';
import '../tools/fetched_data_stream.dart';
import 'repository.dart';

class BaseRepository<T extends Object> implements Repository<T> {
  BaseRepository({required this.gateway, this.isError});

  final Gateway<T> gateway;
  final bool Function(T)? isError;

  FetchedDataStream<T>? _stream;

  @override
  void init() {
    gateway.init();
    if (_stream != null) {
      /// Before [init] you should call [dispose] first
      return;
    }
    _stream = FetchedDataStream();
  }

  @override
  void dispose() {
    _stream?.close();
    _stream = null;
    gateway.dispose();
  }

  @override
  Stream<FetchedData<T>> get stream {
    final streamController = _stream;
    if (streamController == null) {
      throw RepositoryNotInitialized();
    }
    return streamController.stream;
  }

  @override
  RepositoryValue<T> get value {
    final streamController = _stream;
    if (streamController == null) {
      throw RepositoryNotInitialized();
    }
    return switch (streamController.value) {
      SuccessData<T> d => RelevantValue(d.data),
      _ => IrrelevantValue(null),
    };
  }

  @override
  Future<T> fetch(Request request) {
    final streamController = _stream;
    if (streamController == null) {
      throw RepositoryNotInitialized();
    }
    return switch (streamController.value) {
      LoadingData _ => _waitData(),
      _ => _run(request),
    };
  }

  @override
  Future<T> fetchCached(Request request) {
    final streamController = _stream;
    if (streamController == null) {
      throw RepositoryNotInitialized();
    }
    return switch (streamController.value) {
      LoadingData _ => _waitData(),
      SuccessData<T> d => Future.value(d.data),
      _ => _run(request),
    };
  }

  Future<T> _waitData() async {
    final response = await stream.firstWhere(
      (a) => a is ResponseData<T>,
    );
    return (response as ResponseData<T>).data;
  }

  late final bool Function(T?) _isSuccess = switch (isError) {
    final f? => (data) => switch (data) {
          final d? => !f(d),
          _ => false,
        },
    _ => (_) => true,
  };

  Future<T> _run(Request request) async {
    _stream!.emitLoading;
    final newVal = await gateway.fetch(request);
    final emit = _isSuccess(newVal) ? _stream!.emitSuccess : _stream!.emitError;
    emit(newVal);
    return newVal;
  }
}
