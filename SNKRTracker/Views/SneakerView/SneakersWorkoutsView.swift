import SwiftUI

struct SneakersWorkoutsView: View {
    
    let sneaker: SneakerContainer
    
    var body: some View {
        stateView
    }
    
    private var stateView: AnyView {
      let runs = sneaker.data.workouts?.values.compactMap { RunningWorkout(id: $0.id, start: $0.start, end: $0.end, duration: $0.duration, totalEnergyBurned: $0.totalEnergyBurned, totalDistance: $0.totalDistance) }
        guard let workouts = runs else {
            return AnyView(Text("No workouts for \(sneaker.data.model)"))
        }
        
        return AnyView(
            List {
                ForEach(workouts, id: \.self) { workout in
                    Text("\(workout.totalDistance ?? 0.0)")
                }
            }
        )
    }
}
