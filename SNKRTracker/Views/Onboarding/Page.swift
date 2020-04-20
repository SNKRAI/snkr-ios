import Foundation

struct Page: Identifiable {
    let id: UUID
    let image: String
    let heading: String
    let subheading: String
    
    // TODO: add images to assets
    static var pages: [Page] {
        [
            Page(id: UUID(), image: "screen-1", heading: "Track!", subheading: "Lorem ipsum dolor sit amet"),
            Page(id: UUID(), image: "screen-2", heading: "Enable healthkit", subheading: "Lorem ipsum dolor sit amet"),
            Page(id: UUID(), image: "screen-3", heading: "You are all set", subheading: "Lorem ipsum dolor sit amet")
        ]
    }
}
