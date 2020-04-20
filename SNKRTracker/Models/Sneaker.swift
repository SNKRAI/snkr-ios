import Foundation

struct Sneaker: Identifiable, Codable {
    var id = UUID()
    let company: String
    let model: String
}
