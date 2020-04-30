import SwiftUI

struct SneakersWorkoutsView: View {
    
    let sneaker: SneakerContainer
    
    var body: some View {
        stateView
    }
    
    private var stateView: AnyView {
        let runs = sneaker.data.workouts?.compactMap { $0.value }
        guard let workouts = runs else {
            return AnyView(Text("No workouts for \(sneaker.data.model)"))
        }
        
        return AnyView(
            List {
                ForEach(workouts, id: \.self) { workout in
                    NavigationLink(destination: WorkoutDetailView(workoutId: workout.id)) {
                        Text(workout.distance?.distanceString ?? "")
                    }
                }
            }
        )
    }
}
