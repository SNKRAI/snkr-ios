import SwiftUI

struct PendingRunsView: View {
    var runs: [RunningWorkoutContainer]
    var body: some View {
        VStack(alignment: .leading) {
            Section(header: HeaderView(text: "Pending workouts").padding(.horizontal, Layout.headerPadding)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(runs) { run in
                            VStack {
                                Text("\(run.data.totalDistance!)")
                            }
                            .frame(width: 300, height: 200)
                            .background(Color.orange)
                            .cornerRadius(10)
                            .shadow(radius: 5)
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
