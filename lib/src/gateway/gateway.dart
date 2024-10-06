abstract interface class Gateway<T> {
  Future<T> run();
  void dispose();
}
