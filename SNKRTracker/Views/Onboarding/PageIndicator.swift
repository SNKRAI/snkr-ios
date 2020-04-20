import SwiftUI

struct PageIndicator: View {
    
    var currentIndex = 0
    var pagesCount = Page.pages.count
    var onColor = Color.accentColor
    var offColor = Color.blue
    var diameter: CGFloat = 10
    
    var body: some View {
        HStack{
            ForEach(0..<pagesCount) { i in
                Image(systemName: "circle.fill").resizable()
                    .foregroundColor(i == self.currentIndex ? self.onColor : self.offColor)
                    .frame(width: self.diameter, height: self.diameter)
            }
        }
    }
}
