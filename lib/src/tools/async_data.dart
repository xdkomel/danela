sealed class AsyncData<T> {
  const AsyncData();
}

class NoData<T> extends AsyncData<T> {
  const NoData();
}

class LoadingData<T> extends AsyncData<T> {
  const LoadingData();
}

class ResponseData<T> extends AsyncData<T> {
  final T data;
  const ResponseData(this.data);
}
