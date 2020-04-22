import SwiftUI

struct SneakerWorkoutView: View {
    var runs: [SneakerWithWorkouts]

    var body: some View {
        VStack(alignment: .leading) {
            Section(header: HeaderView(text: "Past workouts").padding(.vertical, Layout.headerPadding)) {
                ForEach(runs) { run in
                    VStack {
                        Text("\(run.model)")
                    }
                    .frame(width: UIScreen.main.bounds.width - (Layout.headerPadding * 2), height: 200)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
        }
    }
}
