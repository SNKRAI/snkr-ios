import Foundation

final class AppDefaults {
    static var hasLoadedAlready: Bool {
        UserDefaults.standard.bool(forKey: "hasLoadedAlready")
    }
    
    static var hasPermissions: Bool {
        UserDefaults.standard.bool(forKey: "hasPermissions")
    }
}
