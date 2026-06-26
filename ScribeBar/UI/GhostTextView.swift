import SwiftUI

struct GhostTextView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14)) // Hardcoded for Phase 1, later dynamic via FontMatcher
            .foregroundColor(.gray)
            .opacity(0.8)
            // Ensure no background to stay completely transparent
            .background(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            // Tweak padding to align with typical text field baselines
            .padding(.bottom, 6) 
    }
}
