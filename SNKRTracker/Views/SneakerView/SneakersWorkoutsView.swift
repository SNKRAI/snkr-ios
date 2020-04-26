import SwiftUI

struct SneakersWorkoutsView: View {
    
    let sneaker: SneakerContainer
    
    var body: some View {
        stateView
    }
    
    private var stateView: AnyView {
        let runs = sneaker.data.workouts?.values.compactMap { $0 }
        guard let workouts = runs else {
            return AnyView(Text("No workouts for \(sneaker.data.model)"))
        }
        
        return AnyView(
            List {
                ForEach(workouts, id: \.self) { workout in
                    Text(String(describing: workout.totalDistance?.doubleValue(for: .mile())))
                }
            }
        )
    }
}
