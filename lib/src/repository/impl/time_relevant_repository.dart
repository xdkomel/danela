import 'dart:async';

import '../../../danela.dart';
import '../../tools/fetched_data.dart';

/// [TimeRelevantRepository] adds one more layer of relevancy check to the
/// underlying repository by using the [relevancePeriod] to define if the data
/// is fresh enough.
///
/// [initialDataOutdatesAt] is used for specifying when the data already stored
/// in the repository is considered irrelevant. [null] (default) means the
/// initial data is already irrelevant.
class TimeRelevantRepository<T extends Object, K extends Object>
    extends ProxyRepository<T> {
  TimeRelevantRepository({
    required super.repository,
    required this.relevancePeriod,
    this.initialDataOutdatesAt,
  });

  final Duration relevancePeriod;
  DateTime? initialDataOutdatesAt;

  DateTime? _outdateAt;
  StreamSubscription? _sub;

  @override
  void init() {
    super.init();
    _initOutdateAt();
    _initSub();
  }

  void _initOutdateAt() {
    if (_outdateAt == null && initialDataOutdatesAt != null) {
      _outdateAt = initialDataOutdatesAt;
    }
  }

  void _initSub() {
    if (_sub == null) {
      _sub = repository.stream.listen(
        (d) {
          if (d is SuccessData) {
            _outdateAt = DateTime.now().add(relevancePeriod);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _outdateAt = null;
    _sub?.cancel();
    _sub = null;
  }

  bool get _relevant {
    _initOutdateAt();
    return switch (_outdateAt) {
      final dt? => DateTime.now().isBefore(dt),
      // When the last fetch time is unavailable, ignore it
      _ => false,
    };
  }

  @override
  Future<T> fetch(Request request) {
    _initSub();
    return super.fetch(request);
  }

  @override
  Future<T> fetchCached(Request request) {
    DanelaSettings.observerConfig.onFetchCached?.call(this, request);
    _initSub();
    print('${DateTime.now()}, relevant till ${_outdateAt}');
    final fetchFun = _relevant ? repository.fetchCached : repository.fetch;
    return fetchFun(request);
  }

  @override
  RepositoryValue<T> get value => switch (repository.value) {
        RelevantValue<T> d when _relevant => d,
        RelevantValue<T> d => IrrelevantValue(d.data),
        IrrelevantValue<T> d => IrrelevantValue(d.data),
      };
}
