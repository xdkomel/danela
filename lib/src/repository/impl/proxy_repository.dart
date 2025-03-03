import '../../../danela.dart';
import '../../tools/fetched_data.dart';

/// [ProxyRepository] is a base class for most repositories wrapping another 
/// repository. Wrapping a repository with the [ProxyRepository] supposedly adds 
/// one more layer of ownership and does not change any behavior whatsoever.
class ProxyRepository<A extends Object> implements Repository<A> {
  ProxyRepository({required this.repository});

  final Repository<A> repository;

  @override
  void init() {
    DanelaSettings.observerConfig.onInit?.call(this);
  }

  @override
  void dispose() {
    DanelaSettings.observerConfig.onDispose?.call(this);
  }

  @override
  Future<A> fetch(Request request) {
    DanelaSettings.observerConfig.onFetch?.call(this, request);
    return repository.fetch(request);
  }

  @override
  Future<A> fetchCached(Request request) {
    DanelaSettings.observerConfig.onFetchCached?.call(this, request);
    return repository.fetchCached(request);
  }

  @override
  Stream<FetchedData<A>> get stream => repository.stream;

  @override
  RepositoryValue<A> get value => repository.value;
}
