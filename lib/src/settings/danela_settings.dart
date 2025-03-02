import '../../danela.dart';

/// An object used to adjust the Danela settings. Danela objects should check 
/// the mutable static object in the runtime and modify actions depending on 
/// the config.
abstract class DanelaSettings {
  static var observerConfig = const ObserverConfig();
}

/// The config Danela objects use to log their actions. The first [Object]
/// passed to every function is the function caller.
/// [onLoad] is called when an object clearly loads something. Out of the box, 
/// this is called only by gateways.
/// [onLoadError] is called then an error happened during loading.
/// [onInit] is called when the object is initialized.
/// [onDispose] is called when the object is disposed.
/// [onUsingCached] is called by repositories when they use the cached data 
/// instead of loading.
/// [onWaitingForData] is called by repositories when they has to wait for the 
/// data to come from the previous [fetch] call.
/// [onFetch] is called by repositories and repository clusters when they call 
/// [fetch] for an underlying repository or cluster.
/// [onFetchCached] is called by repositories and repository clusters when they 
/// call [fetchCached] for an underlying repository or cluster.
/// [onRepositoryCreated] is called when a repository cluster creates a new 
/// repository.
/// [onOther] is created for other calls "just in case".
class ObserverConfig {
  const ObserverConfig({
    this.onLoad,
    this.onLoadError,
    this.onInit,
    this.onDispose,
    this.onUsingCached,
    this.onWaitingForData,
    this.onFetch,
    this.onFetchCached,
    this.onRepositoryCreated,
    this.onOther,
  });

  final void Function(Object, Request)? onLoad;
  final void Function(Object, Object, StackTrace)? onLoadError;
  final void Function(Object)? onInit;
  final void Function(Object)? onDispose;
  final void Function(Object, Request, Object)? onUsingCached;
  final void Function(Object, Request)? onWaitingForData;
  final void Function(Object, Request)? onFetch;
  final void Function(Object, Request)? onFetchCached;
  final void Function(Object, Repository)? onRepositoryCreated;
  final void Function(Object)? onOther;
}
