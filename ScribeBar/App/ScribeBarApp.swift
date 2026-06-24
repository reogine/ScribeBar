import SwiftUI

@main
struct ScribeBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We use Settings to avoid creating a main window automatically,
        // since this is a pure menu bar app with an overlay window.
        Settings {
            EmptyView()
        }
    }
}
