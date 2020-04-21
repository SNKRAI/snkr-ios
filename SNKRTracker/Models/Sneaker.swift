import Foundation

struct Sneaker: Identifiable, Codable, Hashable {
    var id = UUID()
    let company: String
    let model: String
}
