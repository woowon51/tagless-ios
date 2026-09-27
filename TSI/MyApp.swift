import SwiftUI

@main
struct MyApp: App {

    private let bleTest = TSI_test_screen_off()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    startLive()
                }
        }
    }
}
