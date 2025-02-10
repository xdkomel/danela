import 'dart:async';

import '../../danela.dart';
import '../tools/fetched_data.dart';

class TimeRelevantRepository<T extends Object> implements Repository<T> {
  TimeRelevantRepository({
    required this.relevancePeriod,
    required this.repository,
    this.initialDataOutdatesAt,
  });

  final Repository<T> repository;
  final Duration relevancePeriod;
  DateTime? initialDataOutdatesAt;

  DateTime? _outdateAt;
  StreamSubscription? _sub;

  @override
  Stream<FetchedData<T>> get stream => repository.stream;

  @override
  void init() {
    repository.init();
    _outdateAt = initialDataOutdatesAt;
    _sub = repository.stream.listen(
      (d) => switch (d) {
        SuccessData() => _outdateAt = DateTime.now().add(relevancePeriod),
        _ => null,
      },
    );
  }

  @override
  void dispose() {
    _outdateAt = null;
    _sub?.cancel();
    _sub = null;
    repository.dispose();
  }

  bool get _relevant => switch (_outdateAt) {
        final dt? => DateTime.now().isBefore(dt),
        // When the last fetch time is unavailable, ignore it
        _ => false,
      };

  @override
  Future<T> fetch(Request request) => repository.fetch(request);

  @override
  Future<T> fetchCached(Request request) {
    final fetch = _relevant ? repository.fetchCached : repository.fetch;
    return fetch(request);
  }

  @override
  RepositoryValue<T> get value => switch (repository.value) {
        RelevantValue<T> d when _relevant => d,
        RelevantValue<T> d => IrrelevantValue(d.data),
        IrrelevantValue<T> d => IrrelevantValue(d.data),
      };
}
