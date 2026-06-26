import Cocoa
import Combine

class CompletionCoordinator {
    static let shared = CompletionCoordinator()
    
    private let overlayWindow = OverlayWindow()
    private var cancellables = Set<AnyCancellable>()
    private var inferenceTask: Task<Void, Never>?
    
    private let textChangedSubject = PassthroughSubject<AXUIElement, Never>()
    
    init() {
        setupPipeline()
        
        NotificationCenter.default.addObserver(
            forName: .textOrCursorChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let object = notification.object else { return }
            let element = object as! AXUIElement
            
            // Immediately hide overlay if user is typing
            self?.overlayWindow.hide()
            self?.inferenceTask?.cancel()
            
            self?.textChangedSubject.send(element)
        }
    }
    
    private func setupPipeline() {
        textChangedSubject
            // Debounce for 400ms as defined in ADR/Context
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] element in
                self?.triggerInference(for: element)
            }
            .store(in: &cancellables)
    }
    
    private func triggerInference(for element: AXUIElement) {
        inferenceTask?.cancel()
        
        inferenceTask = Task { @MainActor in
            guard let context = CursorTracker.shared.getContext(from: element) else { return }
            
            // Enforce minimum context length (8 characters) as per Context.md
            if context.textBeforeCursor.count < 8 {
                return
            }
            
            // Check for cancellation before calling mock engine
            if Task.isCancelled { return }
            
            guard let completion = await MockInferenceEngine.shared.generateCompletion(for: context.textBeforeCursor) else { return }
            
            if Task.isCancelled { return }
            
            self.overlayWindow.showGhostText(completion, at: context.cursorScreenRect)
        }
    }
}
