import '../tools/fetched_data.dart';

import '../../danela.dart';

class SingleListenerRepository<T extends Object> implements Repository<T> {
  SingleListenerRepository({required this.repository, required this.listen});

  final Repository<T> repository;
  final Repository<T> listen;

  @override
  Stream<FetchedData<T>> get stream => repository.stream;

  @override
  void init() => repository.init();

  @override
  void dispose() => repository.init();

  @override
  Future<T> fetch(Request request) => repository.fetch(request);

  @override
  Future<T> fetchCached(Request request) => switch (listen.value) {
        RelevantValue<T> d => Future.value(d.data),
        _ => repository.fetchCached(request),
      };

  @override
  RepositoryValue<T> get value => switch (listen.value) {
        RelevantValue<T> v => v,
        _ => repository.value,
      };
}
