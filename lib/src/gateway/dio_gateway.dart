import 'package:dio/dio.dart';

import '../request.dart';
import '../request_mapper.dart';
import 'gateway.dart';

class DioGateway<T> implements Gateway<T> {
  final Dio dio;
  final Request request;
  final RequestMapper<Response, T>? mapper;
  final void Function(int, int)? onSendProgress;
  final void Function(int, int)? onReceiveProgress;
  final Options? options;
  final _cancelToken = CancelToken();
  DioGateway({
    required this.dio,
    required this.request,
    this.mapper,
    this.onReceiveProgress,
    this.onSendProgress,
    this.options,
  });

  @override
  Future<T> run() async {
    try {
      final response = await _request();
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
    } catch (e) {
      return switch (mapper?.onError) {
        final f? => f(e),
        _ => e as T,
      };
    }
  }

  Future<Response<dynamic>> _request() => switch (request.method) {
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

  @override
  void dispose() => _cancelToken.cancel();
}
