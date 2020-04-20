import SwiftUI

struct PageViewContainer<T: View>: View {

    var viewControllers: [UIHostingController<T>]
    @State var currentPage = 0
    var healthKitManager: HealthKitManagerProtocol
    var completion: (() -> Void) = { }

    var body: some View {
        return VStack {
            PageViewController(controllers: viewControllers, currentPage: self.$currentPage)
            PageIndicator(currentIndex: self.currentPage)
            
            OnboardingBottomButton(text: currentPage == viewControllers.count - 1 ? "Get started" : "Next") {
                if self.currentPage < self.viewControllers.count - 1 {
                    self.currentPage += 1
                } else {
                    self.healthKitManager.requestHealthKitPermissions { result in
                        switch result {
                        case .success:
                            self.completion()
                        case .failure(let error):
                            print("error")
                        }
                    }
                }
            }.padding()
        }
        .background(Color.purple)
    }
}
