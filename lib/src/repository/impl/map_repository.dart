import '../../../danela.dart';
import '../../tools/fetched_data.dart';

/// [MapRepository] maps the data from one repository using the [map] function.
class MapRepository<A extends Object, B extends Object>
    implements Repository<B> {
  MapRepository({required this.repository, required this.map});

  final Repository<A> repository;
  final B Function(A) map;

  @override
  Stream<FetchedData<B>> get stream => repository.stream.map(
        (d) => switch (d) {
          SuccessData<A> d => SuccessData(map(d.data)),
          ErrorData<A> d => ErrorData(map(d.data)),
          LoadingData<A> _ => LoadingData<B>(),
          NoData<A> _ => NoData<B>(),
        },
      );

  @override
  void init() {
    DanelaSettings.observerConfig.onInit?.call(this);
  }

  @override
  void dispose() {
    DanelaSettings.observerConfig.onDispose?.call(this);
  }

  @override
  Future<B> fetch(Request request) async {
    DanelaSettings.observerConfig.onFetch?.call(this, request);
    final a = await repository.fetch(request);
    return map(a);
  }

  @override
  Future<B> fetchCached(Request request) async {
    DanelaSettings.observerConfig.onFetchCached?.call(this, request);
    final a = await repository.fetchCached(request);
    return map(a);
  }

  @override
  RepositoryValue<B> get value => switch (repository.value) {
        RelevantValue<A> v => RelevantValue(map(v.data)),
        IrrelevantValue<A> v => IrrelevantValue(
            switch (v.data) {
              final v? => map(v),
              _ => null,
            },
          ),
      };
}
