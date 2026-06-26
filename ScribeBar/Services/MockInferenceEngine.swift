import Foundation

class MockInferenceEngine {
    static let shared = MockInferenceEngine()
    
    private var currentTask: Task<Void, Never>?
    
    func generateCompletion(for text: String) async -> String? {
        // Debounce / cancel previous task is handled by the coordinator usually,
        // but for safety we mock a small delay to simulate processing.
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Don't suggest anything if text is too short or already ends with world!
        if text.count < 2 || text.hasSuffix("world!") {
            return nil
        }
        
        // Hardcoded mock ghost text
        return " world!"
    }
}
