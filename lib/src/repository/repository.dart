import '../traits/caching.dart';
import '../traits/listening.dart';

import '../traits/fetching.dart';

// class VerboseData<T> {
//   final bool useCache;
//   final T data;
//   const VerboseData({required this.data, required this.useCache});
// }

sealed class RepositoryValue<T extends Object> {
  const RepositoryValue();
}

class RelevantValue<T extends Object> extends RepositoryValue<T> {
  final T data;
  const RelevantValue(this.data);
}

class IrrelevantValue<T extends Object> extends RepositoryValue<T> {
  final T? data;
  const IrrelevantValue(this.data);
}

abstract interface class Repository<T extends Object>
    implements Fetching<T>, Listening<T>, Caching<T> {
  RepositoryValue<T> get value;
}
