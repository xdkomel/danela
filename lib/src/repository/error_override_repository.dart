import '../../danela.dart';
import '../tools/fetched_data.dart';

class ErrorOverrideRepository<T extends Object> extends ProxyRepository<T> {
  ErrorOverrideRepository({required super.repository, required this.isError});

  final bool Function(T) isError;

  T? _value;

  @override
  late final Stream<FetchedData<T>> stream = repository.stream.map(
    (ad) => switch (ad) {
      ResponseData<T> d when isError(d.data) => ErrorData(d.data),
      ResponseData<T> d => SuccessData(d.data),
      _ => ad,
    },
  );

  @override
  void init() {
    super.init();
    _value = switch (repository.value) {
      RelevantValue<T> rv when !isError(rv.data) => rv.data,
      _ => null,
    };
  }

  @override
  void dispose() async {
    _value = null;
    super.dispose();
  }

  @override
  Future<T> fetch(Request request) async {
    final response = await repository.fetch(request);
    if (!isError(response)) {
      _value = response;
    }
    return response;
  }

  @override
  Future<T> fetchCached(Request request) async {
    final response = await repository.fetchCached(request);
    return _updateWith(response);
  }

  T _updateWith(T data) {
    if (!isError(data)) {
      _value = data;
    }
    return data;
  }

  @override
  RepositoryValue<T> get value => switch (_value) {
        final v? => RelevantValue(v),
        _ => IrrelevantValue(null),
      };
}
