import SwiftUI

struct PendingRunsView: View {
    var runs: [RunningWorkoutContainer]
    
    @State private var showModal = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(header: HeaderView(text: "Pending workouts").padding(.horizontal, Layout.headerPadding)) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.headerPadding) {
                        ForEach(runs) { run in
                            Button(action: {
                                self.showModal = true
                            }) {
                                VStack {
                                    Text("\(run.data.totalDistance!)")
                                }
                                .frame(width: 300, height: 200)
                                .background(Color.orange)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }.sheet(isPresented: self.$showModal) {
                                
                                MySneakersView(source: .pendingWorkout(run.data)).environmentObject(MySneakersViewModel())
                            }
                        }
                    }
                }
            }
        }
    }
}

enum Layout {
    static let headerPadding: CGFloat = 20
}
