import '../../danela.dart';

abstract interface class Fetching<T extends Object> {
  void init();
  void dispose();
  Future<T> fetch(Request request);
}