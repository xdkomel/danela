class LimitedMap<K, V extends Object> {
  LimitedMap({this.limit}) : assert(limit == null || limit > 0);

  final int? limit;

  final _map = <K, V>{};

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map[key] = value;
      return;
    }
    final lim = limit;
    if (lim != null && _map.length >= lim) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  V? get(K key) => _map[key];

  Iterable<V> get values => _map.values;

  void clear() => _map.clear();
}
