import 'package:danela/danela.dart';
import 'package:dio/dio.dart';

class Keys {}

String fromJson(Map<String, dynamic> json) {
  final setup = json['setup'];
  final punch = json['punchline'];
  return '$setup\n$punch';
}

String fromError(Object e) => '$e';

void main() async {
  // Create a request to the Joke API
  final request = const Request(
    url: 'https://official-joke-api.appspot.com/random_joke',
  );
  // Define a mapper producing a String from the Dio's Response
  final mapper = const RequestMapper<Response, String>(
    mapJson: fromJson,
    onError: fromError,
  );
  // Create the Dio instance
  final dio = Dio();
  // Now we define the Gateway
  final gateway = DioGateway(dio: dio, mapper: mapper);
  // Safely fetch the String result
  print(await gateway.fetch(request));

  // Now, let's add caching
  final repository = BaseRepository(gateway: gateway);
  // We're good! Cache usage is set to [true] by default in
  // the [BaseRepository]
  print(await repository.fetchCached(request));

  final refreshKeyRepo = BaseRepository(
    gateway: DioGateway(
      dio: dio,
      mapper: RequestMapper<Response, Keys>(),
    ),
  );
  final accessTokenRepo = SingleListenerRepository(
    listen: MapRepository<Keys, String>(
      map: (rk) => 'key',
      repository: TimeRelevantRepository<Keys>(
        relevancePeriod: const Duration(hours: 1),
        initialDataOutdatesAt: DateTime.now(),
        repository: refreshKeyRepo,
      ),
    ),
    repository: BaseRepository(gateway: DioGateway(dio: dio)),
  );

  print(accessTokenRepo.fetch(request));
}
