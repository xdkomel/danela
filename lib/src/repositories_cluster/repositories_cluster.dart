import '../traits/caching.dart';
import '../traits/fetching.dart';
import '../traits/has_lifecycle.dart';
import '../traits/listenable.dart';

/// An abstract class representing a RepositoriesCluster.
///
/// While Repositories focus on storing or mapping the data, clusters are
/// supposed to operate with multiple repositories.
/// While repositories have a [value] that is the latest value fetched by a
/// repository, clusters are not expected to have a single latest value. Thus,
/// a synchronous call for the "latest cluster value" depends on the cluster
/// implementation—there are numerous ways to interpret the "latest value".
abstract interface class RepositoriesCluster<T extends Object>
    implements HasLifecycle, Fetching<T>, Listenable<T>, Caching<T> {}
