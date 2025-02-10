/// Model for a RequestMapper.
/// T is the return type, the type your response is parsed to.
/// R is the response type. If you're using Dio, it is [Response].
///
/// The order in which a gateway checks mappers is [mapResponse] -> [mapData]
/// -> [mapJson]. The first appropriate mapper is then used to map the response.
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
