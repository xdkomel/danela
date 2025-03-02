import '../tools/fetched_data.dart';

abstract interface class Listenable<T extends Object> {
  Stream<FetchedData<T>> get stream;
}