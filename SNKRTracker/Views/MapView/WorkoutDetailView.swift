import SwiftUI
import MapKit
import HealthKit

struct WorkoutDetailView: View {
    @ObservedObject var viewModel = WorkoutDetailViewModel(healthKitManager: HealthKitManager())
    var workoutId: UUID
    
    var body: some View {
        NavigationView {
            MapView(with: viewModel.locations).edgesIgnoringSafeArea(.all)
        }.onAppear {
            self.viewModel.getWorkoutRoute(for: self.workoutId)
        }
    }
}
