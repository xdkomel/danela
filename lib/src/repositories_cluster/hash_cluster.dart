import 'dart:async';

import '../gateway/gateway.dart';
import '../repository/repository.dart';
import '../request.dart';
import '../tools/fetched_data.dart';
import '../tools/limited_map.dart';
import 'errors/not_initialized_cluster.dart';
import 'repositories_cluster.dart';

class HashCluster<T extends Object, K extends Object>
    implements RepositoriesCluster<T> {
  HashCluster({
    required this.gateway,
    required this.createRepository,
    required this.computeKey,
    this.limit,
  });

  final Gateway gateway;
  final Repository<T> Function(Gateway) createRepository;
  final K Function(Request) computeKey;
  int? limit;

  late final _map = LimitedMap<K, Repository<T>>(limit: limit);
  late final _subs = <StreamSubscription>[];
  StreamController<FetchedData<T>>? _stream;

  @override
  void init() {
    gateway.init();
    _stream = StreamController.broadcast();
  }

  @override
  void dispose() {
    _stream?.close();
    _stream = null;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    for (final r in _map.values) {
      r.dispose();
    }
    _map.clear();
    gateway.dispose();
  }

  @override
  Stream<FetchedData<T>> get stream {
    final streamController = _stream;
    if (streamController == null) {
      throw NotInitializedCluster();
    }
    return streamController.stream;
  }

  Repository<T> _newRepository() {
    final streamController = _stream;
    if (streamController == null) {
      throw NotInitializedCluster();
    }
    final repository = createRepository(gateway);
    repository.init();
    _subs.add(repository.stream.listen(streamController.add));
    return repository;
  }

  Repository<T> _repository(Request request) =>
      _map.get(computeKey(request)) ?? _newRepository();

  @override
  Future<T> fetch(Request request) => _repository(request).fetch(request);

  @override
  Future<T> fetchCached(Request request) =>
      _repository(request).fetchCached(request);
}
