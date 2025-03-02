# Danela

**Danela** (**D**art **A**bstract **Ne**twork **La**yer) is a robust and flexible framework designed to simplify data fetching, caching, and processing in Dart and Flutter projects. It provides a structured approach to managing data flow, ensuring consistency, and reducing boilerplate code. Danela is built around the concepts of **`Gateways`**, **`Repositories`**, and **`Clusters`**, which work together to handle data fetching, storage, and transformation. 
It is particularly suited for applications that require frequent data updates, caching, and complex data transformations.

![Danela scheme](https://github.com/xdkomel/danela/blob/main/imgs/scheme.png?raw=true)

## Installation

```yaml
# pubspec.yaml
dependencies:
  danela: ^2.0.0
```

## Usage

Danela operates with two data types. They do nothing but define the characteristics of an action. You can compare them to Flutter widgets that act as a blueprint for the actual UI.
- `Requests` describe the action of requesting something from the Internet.
- `RequestMappers` describe the way raw response data is processed and mapped to the final model.

As for the actions over data types, there are three concepts:
- `Gateways` handle data fetching from external sources and map the resulting data to the domain model.
- `Repository` store and process uniform data it gets (supposedly) from a `Gateway`.
- `RepositoryCluster` manages multiple repositories. 

```dart
// We'll be doing requests to the Joke API
final request = Request(
    url: 'https://official-joke-api.appspot.com/random_joke',
);

// Define a mapper producing a String from the Dio's [Response]
final mapper = RequestMapper<Response, String>(
    mapJson: Joke.fromJson,
    onError: parseError,
);

// Create a gateway to load the data using this mapper while tracking the 
// loading progress
final gateway = DioGateway(
    dio: Dio(), 
    mapper: mapper,
    onReceiveProgress: (r, t) => print('Loading ${r / t * 100}%'),
);

// Safely fetch the ready to use String result! No need to worry about 
// exceptions, they are all caught by the Gateway
print(await gateway.fetch(request));

// This would cancel an unfinished request if there are any using the 
// cancel token. For many cases this could be it: a safe and straightforward way 
// to fetch data
gateway.dispose();

// Now let's add caching using [BaseRepository]
final repository = BaseRepository(gateway: gateway);

// Run [fetchCached] to use cache. This is the first time this repository 
// fetches, so the cache is empty
print(await repository.fetchCached(request));

// This time it will complete immediately due to cache use
print(await repository.fetchCached(request));
```

### Repositories

Similarities between Danela and Flutter don't end on immutability of data structures—repositories can contain **another repositories** declaratively describing the process of data retrieval and processing.

##### `BaseRepository`

It implements the basic caching and streaming strategy, owns a gateway used to load the data. 

It can also define whether the fetched data represents an error or not. Errors are considered irrelevant data, thus, if an error was obtained, `BaseRepository` would not use cache on the next `fetchCached` and would `fetch` the response through the gateway.

```dart
final repo = BaseRepository(
    gateway: gateway,
    isError: (data) => data is ErrorDataModel
);
// [stream] can be listened
repo.stream.listen((a) {
    if (a is SuccessData) {
        print('Successfully fetched ${a.data}!');
    }
});
// [value] can be used to check the latest cached value
final lastValue = repo.value;
if (lastValue is RelevantValue) {
    print('Last value is ${lastValue.data}');
}
```

##### `TimeRelevantRepository`

When the data is fresh only for a limited amount of time, use `TimeRelevantRepository` to automatically disable cache when the data becomes irrelevant.

```dart
final relevantNewsRepository = TimeRelevantRepository(
    repository: newRepository,
    // News are considered old after 5 minutes
    relevancePeriod: Duration(minutes: 5)
);
```

##### `SingleListenerRepository` and `MultiListenerRepository`

Say, you have a repository that fetches the data you need in one place A but it is not its main use. Another place B has its own repository which fetches a specific thing from A and you'd like to utilize the data from A and not load the same thing twice. This is where the `SingleListenerRepository` comes in handy.

```dart
final effectiveAccessTokenRepo = SingleListenerRepository(
    // [MapRepository] simply maps every piece of data 
    listen: MapRepository(
        map: (rk) => rk.accessKey,
        // The access key becomes irrelevant in 1 hour
        repository: TimeRelevantRepository(
            relevancePeriod: Duration(hours: 1),
            // The refresh key repository can provide us with the access key
            repository: refreshKeyRepo,
        ),
    ),
    repository: accessTokenRepo,
);
// Will use the data obtained by the [refreshKeyRepo] if it's still relevant, 
// fetch otherwise
accessTokenRepo.fetchCached(request);
```

`MultiListenerRepository` is the same thing but it has to check all the N repositories you provide it with. The check complexity is O(N).

##### `ProxyRepository`
Say, you want to implement your own repository, use `ProxyRepository` as the base and then override the methods. Used just as is, `ProxyRepository` does nothing but adding one more layer of ownership.

```dart
class MyRepository<T extends Object> extends ProxyRepository<T> {
    MyRepository(super.repository)

    @override
    void init() {
        super.init();
        // Init logic...
    }

    @override
    void dispose() {
        super.dispose();
        // Dispose logic...
    }
}
```

##### Caution: Different Instances

When a repository is used in several places simultaneously, a confusion may arise regarding the cache that is shared between those two places since the repository is one. When you don't want caches and fetches to mingle, simply use different instances. When a newly created repository is local to the project, set proper cache in its `init`.

```dart
// Bookmarks Page
final relevancePeriod = Duration(minutes: 5);
final userInfoRepo = TimeRelevantRepository(
    relevancePeriod: relevancePeriod,
    // Say, you are sure the data is fresh now and you set that in the 
    // constructor which is applied during the [init]
    initialDataOutdatesAt: DateTime.now().add(relevancePeriod)
    // Adding this for the sake of the example
    repository: MapRepository(
        map: (users) => users[uid],
        repository: usersRepo,
    ),
);
```

##### Caution: Lifecycle

Repositories can be `init`ed and `dispose`d to set and free the utilized resources. Though, all out of box repositories initialize on the go, none can dispose automatically. Moreover, a repository shouldn't dispose its child-repository, since it can be used somewhere else fetching or storing important data. Long story short, you have to dispose every repository and gateway yourself when you know it's okay to do so.

### Repositories Clusters

Let's imagine your app allows to search by user-entered queries, hence you have to send requests with constantly changing queries like `{'q': userQuery}`. Are you supposed to create different repositories for every different user query since the normal repository cache does not apply anymore? Well, technically, yes, and you can do it automatically using a `HashCluster`!

```dart
final searchCluster = HashCluster(
    // [g] is actually the gateway from above
    createRepository: () => TimeRelevantRepository(
        relevancePeriod: Duration(minutes: 5), 
        repository: BaseRepository(gateway: gateway)
    ),
    // Limit the amount of created repositories to reduce memory consumption. 
    // [null] means no limit
    limit: 10,
);
searchCluster.fetchCached(
    Request(
        // You have to either provide a key in the Request to map requests to 
        // corresponding repositories, or provide a [computeKey] function in the 
        // tre[HashCluster] constructor
        key: userQuery,
        url: path, 
        queryParameters: {'q': userQuery},
    )
);
```

## Settings and Observer

To set global preferences and monitor Danela's activity use `DanelaSettings` and `ObserverConfig`.

```
DanelaSettings.observerConfig = ObserverConfig(
    onLoad: (_, r) => print('LOADING ${r.url}'),
    onUsingCached: (_, r, o) => print('USE CACHED VALUE $o FOR URL: ${r.url}'),
);
```

## Comparison with [Retrofit](https://pub.dev/packages/retrofit) and [Chopper](https://github.com/lejard-h/chopper)

Danela generally does the same thing, more or less, but without code generation. Due to more freedom, rest clients can be defined at same time when instantiated, which raises questions about the files organization and project architecture. I believe, in the hands of a careless developer, Danela can easily lead to a mess. There's probably less chance of it with Retrofit or Chopper.

In my opinion, Danela has a completely different, new approach to the network layer organization making it scalable and composable. It could easily be used along with the libraries mentioned above, though it would require you to implement a new [Repository]. Then all the concepts would still be applicable and repositories—compatible with each other. This means to me Danela has its charm and place.

## Testing

For tests you may implement a `MockGateway`.

```dart
class MockGateway<T extends Object> implements Gateway<T> {
    @override
    void init() {}
    
    @override
    void dispose() {}

    // You can use [key] to mask the object you expect to receive while fetching
    @override
    Future<T> fetch(Request request) => request.key!;
}
```

## Using [`fpdart`](https://pub.dev/packages/fpdart)

If you're a functional programming enjoyer, leverage its beauty and conciseness easily.

```dart
// Use a mapper with Either
final mapper = RequestMapper<Response, Either<String, Joke>>(
    mapJson: (json) => Either.of(Joke.fromJson(json)),
    onError: (e) => '$e',
);

// Define the gateway as usual
final gateway = DioGateway(
    dio: dio,
    request: request,
    mapper: mapper,
);

// Wrap the run with a TaskEither 
final gatewayTask = TaskEither(gateway.fetch);
```

## Coming from Danela 1

Dear brave Danela 1 users (max 51 people, including me), there are lots of major changes in the second version... However, since the first version was pretty minimal, only several changes would be noticed.

- `run` with the optional `useCache` parameter was replaced with `fetch` and `fetchCached`.
- `DefaultRepository` is now `BaseRepository`.
- `AsyncData` was renamed to `FetchedData` to avoid collisions with the `AsyncData` from the `dart:async`.
- `ResponseData` now can be either `SuccessData` or `ErrorData`.
- `Request`s have keys now.

## Contacts

The package is in development, so in case of problems or suggestions, feel free to create an issue on [GitHub](https://github.com/xdkomel/danela) or contact me on [Telegram](https://t.me/xdkomel).
