import SwiftUI

struct MenuBarView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.cursor")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Scribe Bar")
                .font(.headline)
            
            Text("Privacy-first AI autocomplete")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            Button("Settings...") {
                // TODO: Open settings window
            }
            
            Button("Quit Scribe Bar") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 300, height: 250)
    }
}

#Preview {
    MenuBarView()
}
