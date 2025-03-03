import '../../../danela.dart';
import 'package:collection/collection.dart';

/// [MultiListenerRepository] uses multiple [listen] repository's cache to 
/// reduce loading calls of the underlying [repository]. 
class MultiListenerRepository<T extends Object> extends ProxyRepository<T> {
  MultiListenerRepository({required super.repository, required this.listen});

  final List<Repository<T>> listen;

  RelevantValue<T>? get _firstRelevantFromListen {
    final value = listen
        .map((r) => r.value)
        .firstWhereOrNull((v) => v is RelevantValue<T>);
    return value == null ? null : value as RelevantValue<T>;
  }

  @override
  Future<T> fetchCached(Request request) {
    DanelaSettings.observerConfig.onFetchCached?.call(this, request);
    return switch (_firstRelevantFromListen) {
      RelevantValue<T> d => Future.value(d.data),
      _ => repository.fetchCached(request),
    };
  }

  @override
  RepositoryValue<T> get value => switch (_firstRelevantFromListen) {
        RelevantValue<T> v => v,
        _ => repository.value,
      };
}
