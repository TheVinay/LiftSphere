import SwiftUI

struct RootView: View {
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false

    var body: some View {
        if !didChooseLogin {
            WelcomeView()
        } else {
            RootTabView()   // Your existing tab view
        }
    }
}
