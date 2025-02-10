import '../traits/caching.dart';
import '../traits/fetching.dart';
import '../traits/listening.dart';

abstract interface class RepositoriesCluster<T extends Object>
    implements Fetching<T>, Listening<T>, Caching<T> {}
