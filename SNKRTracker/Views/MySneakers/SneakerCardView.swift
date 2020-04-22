import SwiftUI

struct SneakerCardView: View {
    var container: [SneakerContainer]
    var viewModel: MySneakersViewModel
    
    var body: some View {
        List {
            ForEach(container, id: \.self) { model in
                SneakerCardRow(sneaker: model.data)
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

