import SwiftUI
import MapKit
import HealthKit

struct MyRunsDetailView: View {
    @ObservedObject var viewModel = MyRunsDetailViewModel(healthKitManager: HealthKitManager())
    var workout: HKWorkout
    
    var body: some View {
        NavigationView {
            MapView(with: viewModel.locations).edgesIgnoringSafeArea(.all)
        }.onAppear {
            self.viewModel.getWorkoutRoute(for: self.workout)
        }
    }
}
