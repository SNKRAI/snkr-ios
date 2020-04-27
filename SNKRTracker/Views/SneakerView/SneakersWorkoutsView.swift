import SwiftUI
import HealthKit

struct SneakersWorkoutsView: View {
    
    let sneaker: SneakerContainer
    
    var body: some View {
        stateView
    }
    
    private var stateView: AnyView {
        guard let workouts = sneaker.data.workouts else {
            return AnyView(Text("No workouts for \(sneaker.data.model)"))
        }
        
        return AnyView(
            List {
                ForEach(workouts, id: \.self) { workout in
                    NavigationLink(destination: MyRunsDetailView(workout: workout.data)) {
                        Text(String(describing: workout.data.totalDistance?.doubleValue(for: .mile())))
                    }
                }
            }
        )
    }
    
//    private func isInDoorRun(_ workout: HKWorkout) -> Bool {
//        let indoor = workout.metadata?.first { $0.key == "" }
//        return true
//    }
}
