import 'package:danela/danela.dart';
import 'package:dio/dio.dart';

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
  // Define a mapper producing a String from a Dio's Response
  // (since we are using Dio here)
  final mapper = const RequestMapper<Response, String>(
    mapJson: fromJson,
    onError: fromError,
  );
  // Create the Dio instance
  final dio = Dio();
  // Now we define the Gateway
  final gateway = DioGateway(
    dio: dio,
    request: request,
    mapper: mapper,
  );
  // Safely fetch the String result
  print(await gateway.run());

  // Now, let's add caching
  final repository = DefaultRepository(gateway: gateway);
  // We're good! Cache usage is set to [true] by default in
  // the [DefaultRepository]
  print(await repository.run(useCache: true));
}
