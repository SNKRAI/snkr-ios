import SwiftUI

struct SneakerCardView: View {
    let container: [SneakerContainer]
    let viewModel: MySneakersViewModel
    let source: Source
    
    var body: some View {
        List {
            ForEach(container, id: \.self) { model in
                Button(action: {
                    switch self.source {
                    case .pendingWorkout(var workout):
                        workout.sneaker = model.data
                        self.viewModel.rowSelected(with: workout)
                    case .runsView:
                        print("open details view may be?")
                    }
                }) {
                    SneakerCardRow(sneaker: model.data)
                }
            }.onDelete { indexSet in
                self.viewModel.delete(at: indexSet, in: self.container)
            }
        }.navigationBarItems(trailing:
             NavigationLink(destination:
                SneakerSearchView().environmentObject(SneakerSearchViewModel())
             ) {
                 Text("Add more")
             }
         )
    }
}

struct SneakerCardRow: View {
    var sneaker: Sneaker
    var body: some View {
        Text(sneaker.model)
    }
}

