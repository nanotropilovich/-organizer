
import SwiftUI

@main
struct orgApp: App {
    var recordsManager = RecordsManager()
    var body: some Scene {
        WindowGroup {
                   ContentView()
                       .environmentObject(recordsManager)
               }
    }
}
