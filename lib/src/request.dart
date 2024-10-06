enum Method { get, post, delete, put, patch, head }

class Request {
  final String url;
  final Method method;
  final Object? data;
  final Map<String, dynamic>? queryParameters;
  const Request({
    required this.url,
    this.method = Method.get,
    this.data,
    this.queryParameters,
  });
}
