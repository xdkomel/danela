import 'dart:async';

import '../../settings/danela_settings.dart';

import '../../gateway/gateway.dart';
import '../../request.dart';
import '../../tools/fetched_data.dart';
import '../../tools/fetched_data_stream.dart';
import '../repository.dart';

/// [BaseRepository] wraps a [Gateway] which is used to fetch the data and
/// implements the most basic [Repository] functionality.
///
/// [BaseRepository] caches the response in the runtime. When another
/// [fetchCached] is made, it will firstly check the cache. When a request is
/// made while another isn't finished, the repository waits for the previous
/// request to complete and then returns one result for both.
///
/// [gateway] is the underlying gateway.
/// [isError] specifies which state is considered to be an error. Note, this
/// does not mean an error happened while fetching the data! This error is
/// formal, when the response is mapped to an object considered to be an error.
/// The only type of data considered irrelevant is errors.
class BaseRepository<T extends Object> implements Repository<T> {
  BaseRepository({required this.gateway, this.isError});

  final Gateway<T> gateway;
  final bool Function(T)? isError;

  FetchedDataStream<T>? _stream;

  @override
  void init() {
    DanelaSettings.observerConfig.onInit?.call(this);
    if (_stream == null) {
      _stream = FetchedDataStream();
    }
  }

  @override
  void dispose() {
    DanelaSettings.observerConfig.onDispose?.call(this);
    _stream?.close();
    _stream = null;
  }

  void _initIfNeeded() {
    if (_stream == null) {
      init();
    }
  }

  @override
  Stream<FetchedData<T>> get stream {
    _initIfNeeded();
    return _stream!.stream;
  }

  @override
  RepositoryValue<T> get value {
    _initIfNeeded();
    return switch (_stream!.value) {
      SuccessData<T> d => RelevantValue(d.data),
      _ => const IrrelevantValue(null),
    };
  }

  @override
  Future<T> fetch(Request request) {
    _initIfNeeded();
    return switch (_stream!.value) {
      LoadingData _ => _waitData(request),
      _ => _load(request),
    };
  }

  @override
  Future<T> fetchCached(Request request) {
    _initIfNeeded();
    return switch (_stream!.value) {
      LoadingData _ => _waitData(request),
      SuccessData<T> d => _useCache(request, d.data),
      _ => _load(request),
    };
  }

  Future<T> _useCache(Request req, T value) {
    DanelaSettings.observerConfig.onUsingCached?.call(this, req, value);
    return Future.value(value);
  }

  Future<T> _waitData(Request req) async {
    DanelaSettings.observerConfig.onWaitingForData?.call(this, req);
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

  Future<T> _load(Request request) async {
    DanelaSettings.observerConfig.onFetch?.call(this, request);
    _stream!.emitLoading();
    final newVal = await gateway.fetch(request);
    final emit = _isSuccess(newVal) ? _stream!.emitSuccess : _stream!.emitError;
    emit(newVal);
    return newVal;
  }
}
