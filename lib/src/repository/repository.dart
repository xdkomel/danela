import '../traits/caching.dart';
import '../traits/has_lifecycle.dart';
import '../traits/listenable.dart';
import '../traits/fetching.dart';

/// An abstract class representing a [Repository].
/// 
/// Repositories store and process uniform data. The data is considered uniform 
/// (enough) if every new instance of that data can substitute the previous one.
/// 
/// The only thing repositories shouldn't do is fetching the data directly, 
/// consider transferring this responsibility to a [Gateway]. 
/// 
/// Except for [Caching], repositories are also listenable. Fetch results can be 
/// observed in the stream provided by the [Listenable] trait.
/// 
/// One more thing is the data relevancy. Since repositories fetch uniform data 
/// that is cached, the cache can become obsolete after some time or on specific 
/// occasions. So to manage that there is a an additional wrapper 
/// [RepositoryValue] which contains the most recent repository cache value 
/// tagged as either relevant or irrelevant.
abstract interface class Repository<T extends Object>
    implements HasLifecycle, Fetching<T>, Listenable<T>, Caching<T> {
  RepositoryValue<T> get value;
}

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
