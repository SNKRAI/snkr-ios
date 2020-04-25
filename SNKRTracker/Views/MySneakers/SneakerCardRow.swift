import SwiftUI

struct SneakerCardRow: View {
    var sneaker: Sneaker
    var body: some View {
        VStack {
            Text(sneaker.company)
            Text(sneaker.model)
            Text(totalDistance?.distanceString ?? "")
        }
        .frame(width: UIScreen.main.bounds.width - (Layout.padding * 2), height: 200)
        .background(Color.gray)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    var totalDistance: Double? {
        guard let workouts = sneaker.workouts?.values else { return nil }
        return workouts.compactMap { $0.totalDistance }.reduce(0, +)
    }
}
