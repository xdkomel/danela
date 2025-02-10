import '../../danela.dart';
import '../tools/fetched_data.dart';

class ProxyRepository<A extends Object> implements Repository {
  ProxyRepository({required this.repository});

  final Repository<A> repository;

  @override
  void dispose() => repository.dispose();

  @override
  Future<Object> fetch(Request request) => repository.fetch(request);

  @override
  Future<Object> fetchCached(Request request) =>
      repository.fetchCached(request);

  @override
  void init() => repository.init();

  @override
  Stream<FetchedData<A>> get stream => repository.stream;

  @override
  RepositoryValue<A> get value => repository.value;
}
