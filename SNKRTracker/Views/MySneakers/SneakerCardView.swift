import SwiftUI

struct SneakerCardView: View {
    let container: [SneakerContainer]
    let viewModel: MySneakersViewModel
    let source: Source
    let completion: (() -> Void)

    var body: some View {
        List {
            ForEach(container, id: \.self) { model in
                Button(action: {
                    switch self.source {
                    case .pendingWorkout(let workout):
                        self.viewModel.save(workout: workout, for: model) { result in
                            if case .success = result {
                                self.completion()
                            }
                        }
                    default:
                        break
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
