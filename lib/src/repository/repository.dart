abstract interface class Repository<T> {
  Future<T> run();
  void dispose();
}
