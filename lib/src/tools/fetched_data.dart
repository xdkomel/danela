sealed class FetchedData<T> {
  const FetchedData();
}

class NoData<T> extends FetchedData<T> {
  const NoData();
}

class LoadingData<T> extends FetchedData<T> {
  const LoadingData();
}

sealed class ResponseData<T> extends FetchedData<T> {
  final T data;
  const ResponseData(this.data);
}

class SuccessData<T> extends ResponseData<T> {
  const SuccessData(super.data);
}

class ErrorData<T> extends ResponseData<T> {
  const ErrorData(super.data);
}
