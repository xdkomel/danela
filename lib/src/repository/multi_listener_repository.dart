import 'repository.dart';
import '../request.dart';
import '../tools/fetched_data.dart';
import 'package:collection/collection.dart';

class MultiListenerRepository<T extends Object> implements Repository<T> {
  MultiListenerRepository({required this.repository, required this.listen});

  final Repository<T> repository;
  final List<Repository<T>> listen;

  @override
  Stream<FetchedData<T>> get stream => repository.stream;

  @override
  void init() => repository.init();

  @override
  void dispose() => repository.dispose();

  RelevantValue<T>? get _firstRelevantFromListen {
    final value = listen
        .map((r) => r.value)
        .firstWhereOrNull((v) => v is RelevantValue<T>);
    return value == null ? null : value as RelevantValue<T>;
  }

  @override
  Future<T> fetch(Request request) => repository.fetch(request);

  @override
  Future<T> fetchCached(Request request) => switch (_firstRelevantFromListen) {
        RelevantValue<T> d => Future.value(d.data),
        _ => repository.fetchCached(request),
      };

  @override
  RepositoryValue<T> get value => switch (_firstRelevantFromListen) {
        RelevantValue<T> v => v,
        _ => repository.value,
      };
}
