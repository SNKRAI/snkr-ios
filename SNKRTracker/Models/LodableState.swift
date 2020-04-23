enum LoadableState<T> {
    case loading
    case empty
    case fetched(T)
    case error(FetchError)
}
