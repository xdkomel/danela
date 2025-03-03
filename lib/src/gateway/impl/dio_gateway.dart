import 'dart:async';

import '../../../danela.dart';
import 'package:dio/dio.dart';

import '../errors/error_not_mapped_error.dart';

/// [DioGateway] wraps Dio calls. It can only fetch and map the response, also
/// providing abilities to Dio features like callbacks for the
/// [onSendProgress] and [onReceiveProgress].
///
/// [mapper] is used to map the responses to the T.
/// [options] are passed to every Dio request.
class DioGateway<T extends Object> implements Gateway<T> {
  DioGateway({
    required this.dio,
    this.mapper,
    this.onReceiveProgress,
    this.onSendProgress,
    this.options,
  });

  final Dio dio;
  final RequestMapper<Response, T>? mapper;
  final void Function(int, int)? onSendProgress;
  final void Function(int, int)? onReceiveProgress;
  final Options? options;
  CancelToken? _cancelToken;

  @override
  void init() {
    DanelaSettings.observerConfig.onInit?.call(this);
  }

  @override
  void dispose() {
    DanelaSettings.observerConfig.onDispose?.call(this);
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  @override
  Future<T> fetch(Request request) async {
    try {
      DanelaSettings.observerConfig.onLoad?.call(this, request);
      final response = await _request(request);
      return switch (mapper?.mapResponse) {
        final f? => f(response),
        _ => switch (mapper?.mapData) {
            final f? => f(response.data),
            _ => switch (mapper?.mapJson) {
                final f? => f(response.data as Map<String, dynamic>),
                _ => response.data as T,
              }
          }
      };
    } catch (e, st) {
      DanelaSettings.observerConfig.onLoadError?.call(this, e, st);
      return switch (mapper?.onError) {
        final f? => f(e),
        _ => throw ErrorNotMappedError(),
      };
    }
  }

  Future<Response<dynamic>> _request(Request request) {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    return switch (request.method) {
      Method.get => dio.get(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: _cancelToken,
          onReceiveProgress: onReceiveProgress,
          options: options,
        ),
      Method.post => dio.post(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: _cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          options: options,
        ),
      Method.put => dio.put(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: _cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          options: options,
        ),
      Method.patch => dio.patch(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: _cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          options: options,
        ),
      Method.delete => dio.delete(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: _cancelToken,
          options: options,
        ),
      Method.head => dio.head(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: _cancelToken,
          options: options,
        ),
    };
  }
}
