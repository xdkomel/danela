import '../traits/fetching.dart';
import '../traits/has_lifecycle.dart';

/// An abstract class representing a [Gateway].
///
/// Gateways wrap a library fetch calls, so that its abilities narrow down to
/// simple but unified fetching. No storing or complex (asynchronous) data
/// processing is supposed to be happening in a gateway. These are just data
/// providers, while [Repositories] focus more on storing and processing.
abstract interface class Gateway<T extends Object>
    implements HasLifecycle, Fetching<T> {}
