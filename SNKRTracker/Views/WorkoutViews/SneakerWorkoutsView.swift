import SwiftUI

struct SneakerWorkoutsView: View {
    
    var runs: [RunningWorkoutContainer]
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(header: HeaderView(text: "Past workouts")) {
                VStack(spacing: 20) {
                    ForEach(runs) { run in
                        Image("zoom2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width - (Layout.headerPadding * 2), height: 200)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
    }
}
