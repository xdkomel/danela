/// Model for a RequestMapper.
/// T is the return type, R is the response type
class RequestMapper<R, T> {
  final T Function(Map<String, dynamic> json)? mapJson;
  final T Function(dynamic data)? mapData;
  final T Function(R resp)? mapResponse;
  final T Function(Object e)? onError;
  const RequestMapper({
    this.mapJson,
    this.mapData,
    this.mapResponse,
    this.onError,
  });
}
