## 2.0.0

- `run` with the optional `useCache` parameter was replaced with `fetch` and `fetchCached`.
- `DefaultRepository` is now `BaseRepository`.
- `AsyncData` was renamed to `FetchedData` to avoid collisions with the `AsyncData` from the `dart:async`.
- `ResponseData` now can be either `SuccessData` or `ErrorData`.
- `Request`s have keys now.
- Added new concept, `RepositoriesCluster`. Currently, there's only one successor—`HashCluster`.
- Added new repositories: `TimeRelevant...`, `Map...`, `SingleListener...`, `MultiListener...`.
- Added settings and an observer.
- Documentation for all classes!

## 1.0.1

- Update the image link

## 1.0.0

- Initial version.
