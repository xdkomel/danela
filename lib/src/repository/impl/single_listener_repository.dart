
import '../../../danela.dart';

/// [SingleListenerRepository] uses the [listen] repository's cache to reduce 
/// loading calls of the underlying [repository].
class SingleListenerRepository<T extends Object> extends ProxyRepository<T> {
  SingleListenerRepository({required super.repository, required this.listen});

  final Repository<T> listen;

  @override
  Future<T> fetchCached(Request request) {
    DanelaSettings.observerConfig.onFetchCached?.call(this, request);
    return switch (listen.value) {
      RelevantValue<T> d => Future.value(d.data),
      _ => repository.fetchCached(request),
    };
  }

  @override
  RepositoryValue<T> get value => switch (listen.value) {
        RelevantValue<T> v => v,
        _ => repository.value,
      };
}
