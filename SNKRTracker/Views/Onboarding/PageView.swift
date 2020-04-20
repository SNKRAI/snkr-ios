import SwiftUI

struct PageView: View {
    
    var page = Page.pages.first
    
    var body: some View {
        VStack {
            Image("screen-1")
            VStack{
                Text(page?.heading ?? "").font(.title).bold().layoutPriority(1).multilineTextAlignment(.center)
                Text(page?.subheading ?? "").multilineTextAlignment(.center)
            }.padding()
        }
    }
}
