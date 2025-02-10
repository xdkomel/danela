import '../tools/fetched_data.dart';

abstract interface class Listening<T extends Object> {
  Stream<FetchedData<T>> get stream;
}