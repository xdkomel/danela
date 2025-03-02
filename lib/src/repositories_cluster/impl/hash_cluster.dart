import 'dart:async';

import '../../repository/repository.dart';
import '../../request.dart';
import '../../settings/danela_settings.dart';
import '../../tools/fetched_data.dart';
import '../../tools/limited_map.dart';
import '../repositories_cluster.dart';

/// [HashCluster] stores repositories in a [LinkedHashMap] by keys it computes
/// for every request.
/// [gateway] specifies how every repository will fetch the data.
/// [createRepository] is used to create a new repository, which is associated
/// with a specific key. The function receives the same gateway instance passed
/// to the constructor.
/// [computeKey] defines how a Request is mapped to a key.
/// [limit] specifies the limit of repositories. [null] means no limit. Earlier
/// created repositories are going to be removed first (FIFO).
class HashCluster<T extends Object> implements RepositoriesCluster<T> {
  HashCluster({
    required this.createRepository,
    this.computeKey,
    this.limit,
  });

  final Repository<T> Function() createRepository;
  final Object Function(Request)? computeKey;
  int? limit;

  late final _map = LimitedMap<Object, Repository<T>>(
    limit: limit,
    onRemove: (key, rep) {
      rep.dispose();
      _subs[key]?.cancel();
      _subs.remove(key);
    },
  );
  late final _subs = <Object, StreamSubscription>{};
  StreamController<FetchedData<T>>? _stream;

  @override
  void init() {
    DanelaSettings.observerConfig.onInit?.call(this);
    if (_stream == null) {
      _stream = StreamController.broadcast();
    }
  }

  void _initIfNeeded() {
    if (_stream == null) {
      init();
    }
  }

  @override
  void dispose() {
    DanelaSettings.observerConfig.onDispose?.call(this);
    _stream?.close();
    _stream = null;
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    for (final r in _map.values) {
      r.dispose();
    }
    _map.clear();
  }

  @override
  Stream<FetchedData<T>> get stream {
    _initIfNeeded();
    return _stream!.stream;
  }

  Repository<T> _newRepository() {
    final repository = createRepository();
    DanelaSettings.observerConfig.onRepositoryCreated?.call(this, repository);
    repository.init();
    return repository;
  }

  Object _keyFor(Request req) {
    final key = req.key;
    if (key != null) {
      return key;
    }
    if (computeKey != null) {
      return computeKey!(req);
    }
    throw RequestKeyNotFound();
  }

  Repository<T> _repository(Request request) {
    final key = _keyFor(request);
    var repo = _map.get(key);
    if (repo == null) {
      repo = _newRepository();
      _map.put(key, repo);
      _initIfNeeded();
      _subs[key] = repo.stream.listen(_stream!.add);
    }
    return repo;
  }

  @override
  Future<T> fetch(Request request) {
    DanelaSettings.observerConfig.onFetch?.call(this, request);
    return _repository(request).fetch(request);
  }

  @override
  Future<T> fetchCached(Request request) {
    DanelaSettings.observerConfig.onFetchCached?.call(this, request);
    return _repository(request).fetchCached(request);
  }

  Repository<T>? repositoryForRequest(Request request) {
    final key = _keyFor(request);
    return _map.get(key);
  }

  Repository<T>? repositoryForKey(Object key) => _map.get(key);
}

class RequestKeyNotFound extends Error {}
