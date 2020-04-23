enum LoadableState<T> {
    case loading
    case empty
    case fetched(T)
    case error(FetchError)
}

enum FetchState<T, U> {
    case loading
    case empty
    case fetched(T, U)
    case error(FetchError)
}
