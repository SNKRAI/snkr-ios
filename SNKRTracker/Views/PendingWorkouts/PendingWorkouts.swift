import SwiftUI

struct PendingRunsView: View {
    var runs: [RunningWorkoutContainer]
    var sneakers: [SneakerContainer]
    var completion: () -> Void
    let sneakerCompletion: (SneakerContainer) -> Void

    @State private var showModal = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(header: HeaderView(text: "Pending workouts").padding(.horizontal, Layout.padding)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.padding) {
                        if runs.isEmpty {
                            Text("Empty state")
                        } else {
                            runsView
                        }
                    }
                }
            }
        }
    }
    
    private var runsView: AnyView {
        return AnyView(
            ForEach(runs) { run in
                Button(action: {
                    self.showModal = true
                }) {
                    VStack {
                        Text(String(describing: run.data.totalDistance?.doubleValue(for: .mile())))
                    }
                    .frame(width: 300, height: 200)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }.sheet(isPresented: self.$showModal) {
                    MyRunsDetailView(workout: run.data)
                    
//                    MySneakersView(source: .pendingWorkout(run), completion: {
//                        self.completion()
//                    }) { sneaker in
//                        self.sneakerCompletion(sneaker)
//                    }.environmentObject(MySneakersViewModel())
                }
            }
        )
    }
}

enum Layout {
    static let padding: CGFloat = 20
}
