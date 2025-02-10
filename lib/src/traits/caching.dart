import '../request.dart';

abstract interface class Caching<T extends Object> {
  Future<T> fetchCached(Request request);
}
