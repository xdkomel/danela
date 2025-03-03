import 'package:danela/danela.dart';
import 'package:dio/dio.dart';

String fromJson(Map<String, dynamic> d) => d['setup'];

String fromError(Object e) => '$e';

void main() async {
  DanelaSettings.observerConfig = ObserverConfig(
    onLoad: (_, r) => print('loading ${r.url}'),
    onUsingCached: (_, r, o) => print('use cache $o for ${r.url}'),
    onWaitingForData: (_, r) => print('waiting for ${r.url}'),
    onFetch: (a, r) => print('fetch ${r.url}'),
    onFetchCached: (a, r) => print('fetchCached ${r.url}'),
    onRepositoryCreated: (_, r) => print('created a repository'),
  );
  // We'll be doing requests to the Joke API
  final request = const Request(
    url: 'https://official-joke-api.appspot.com/random_joke',
  );

// Define a mapper producing a String from the Dio's [Response]
  final mapper = const RequestMapper<Response, String>(
    mapJson: fromJson,
    onError: fromError,
  );

// Create a gateway to load the data using this mapper while tracking the
// loading progress
  final gateway = DioGateway(
    dio: Dio(),
    mapper: mapper,
    onReceiveProgress: (r, t) => print('Loading ${r / t * 100}%'),
  );

// Safely fetch the ready to use String result! No need to worry about
// exceptions, they are all caught by the Gateway
  print(await gateway.fetch(request));

// This would cancel an unfinished request if there are any using the
// cancel token. For many cases this could be it: a safe and straightforward way
// to fetch data
  gateway.dispose();

// Now let's add caching using [BaseRepository]
  final repository = BaseRepository(gateway: gateway);

// Run [fetchCached] to use cache. This is the first time this repository
// fetches, so there's no cache
  print(await repository.fetchCached(request));

// This time it will complete immediately due to cache
  print(await repository.fetchCached(request));
}
