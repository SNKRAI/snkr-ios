import SwiftUI

struct SneakersWorkoutsView: View {
    
    let sneaker: SneakerContainer
    
    var body: some View {
        NavigationView {
            if sneaker.data.workouts == nil {
                Text("No workouts for \(sneaker.data.model)")
            } else {
                Text("some workouts")
//                List(sneaker.data.workouts?.values ?? []) { workout in
//                    Text("\(workout.data.totalDistance!)")
//                }
            }
        }
    }
}
