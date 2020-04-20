enum AppError: Swift.Error {
    case apiError
    case noHealthKitPermissions
    case generic(String)
}
