class LimitedMap<K, V extends Object> {
  LimitedMap({required this.onRemove, this.limit})
      : assert(limit == null || limit > 0);

  final int? limit;
  final void Function(K, V) onRemove;

  final _map = <K, V>{};

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map[key] = value;
      return;
    }
    final lim = limit;
    if (lim != null && _map.length >= lim) {
      final removeKey = _map.keys.first;
      final value = _map[removeKey];
      if (value != null) {
        onRemove(removeKey, value);
      }
      _map.remove(removeKey);
    }
    _map[key] = value;
  }

  V? get(K key) => _map[key];

  Iterable<V> get values => _map.values;

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;
}
