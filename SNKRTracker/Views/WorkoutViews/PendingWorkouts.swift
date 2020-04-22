import SwiftUI

struct PendingRunsView: View {
    var runs: [RunningWorkoutContainer]
    var body: some View {
        VStack(alignment: .trailing) {
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

struct PastWorkoutsView: View {
    
    var runs: [RunningWorkoutContainer]
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 20) {
                ForEach(runs) { run in
                    Text("d")
                }
                
                .frame(width: UIScreen.main.bounds.width, height: 200)
                .background(Color.gray)
                .cornerRadius(10)
                .shadow(radius: 10)
            }
        }
    }
}

struct HeadlineView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 20))
            .fontWeight(.heavy)
            .padding(.leading, 20)
    }
}
