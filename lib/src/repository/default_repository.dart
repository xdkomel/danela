import '../gateway/gateway.dart';
import '../tools/async_data.dart';
import '../tools/async_value.dart';
import 'repository.dart';

class DefaultRepository<T> implements Repository {
  final Gateway<T> gateway;
  final bool Function(T)? isError;
  DefaultRepository({
    required this.gateway,
    this.isError,
  });

  final _store = AsyncValue<AsyncData<T>>(const NoData());

  @override
  Future<T> run({bool useCache = true}) => switch (_store.value) {
        LoadingData _ => _waitThenRun(),
        ResponseData<T>(:final data) when _isSuccess(data) && useCache =>
          Future.value(data),
        _ => _run(),
      };

  Future<T> _waitThenRun() async {
    await _store.stream.firstWhere((a) => a is ResponseData);
    return run();
  }

  Future<T> _run() async {
    _store.emit(const LoadingData());
    final newVal = await gateway.run();
    _store.emit(ResponseData(newVal));
    return newVal;
  }

  bool _isSuccess(T data) => switch (isError) {
        final f? => !f(data),
        _ => true,
      };

  @override
  void dispose() {
    gateway.dispose();
    _store.close();
  }
}
