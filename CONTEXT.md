# Scribe Bar — Domain Glossary

> A privacy-first, open-source, local AI writing assistant for macOS that lives in the menu bar. First-class Arabic + English support. Zero telemetry, zero opaque data collection, fully auditable.

## Glossary

| Term | Definition |
|---|---|
| **Scribe Bar** | The macOS menu-bar app. A local AI autocomplete assistant that predicts and suggests text as the user types, across any app. |
| **Completion** | A predicted continuation of the user's current text, shown as ghost text inline. |
| **Ghost Text** | Semi-transparent overlay text rendered ahead of the cursor showing a suggested completion. The user accepts (Tab) or ignores it. |
| **Context** | The combination of signals (typed text, screen content, clipboard) assembled into a prompt for inference. |
| **Inference** | The local execution of a language model to generate a completion. Always on-device, never cloud. |
| **Overlay Window** | A borderless, transparent NSWindow positioned over the active text field to render ghost text. |
| **llama.cpp** | The C/C++ inference engine linked as a dynamic library (`libllama.dylib`) for running GGUF models. |
| **Metal GPU** | Apple's GPU framework used by ggml-metal for hardware-accelerated inference. |
| **Input Channel** | A source of text context fed into the prompt. Scribe Bar has three: Accessibility (required), Screen Context (optional), Clipboard (optional). |
| **Accessibility Reader** | The primary input channel. Uses macOS Accessibility API (`AXUIElement`) to read the focused text field. The only required permission. |
| **Screen Context** | Optional input channel. Uses ScreenCaptureKit + Vision OCR to extract surrounding text from the active window. Requires Screen Recording permission. Available from v1 but off by default. |
| **Clipboard Context** | Optional input channel. Reads the system pasteboard to understand what the user is working with. No extra permission needed. |
| **Hardware Profile** | A snapshot of the user's machine capabilities (chip, RAM, GPU cores, free disk) taken at first launch to determine which models will run with acceptable performance. |
| **Model Recommender** | The setup-time logic that maps a Hardware Profile + language preferences to a recommended model from the Model Catalog. |
| **Model Catalog** | The curated set of GGUF models Scribe Bar supports, organized by size tier and language strength. |
| **Setup Flow** | The first-launch onboarding sequence: detect hardware → select languages → recommend model → download → grant permissions → done. |
| **Writing Profile** | A local, user-inspectable store of typing patterns and style preferences used to personalize completions. Plaintext JSON, never encrypted opaquely, never uploaded. |
| **Personalization** | The system that learns the user's writing style over time from accepted completions and typing context. All data stays on-device with zero network transmission. |
| **Network Boundary** | A hard architectural rule: Scribe Bar makes network calls ONLY for model downloads and update checks. Never for user data, telemetry, analytics, or crash reports. |
| **Cursor Tracker** | Subsystem that queries the active text field's cursor position via `AXSelectedTextRange` + `AXBoundsForRange` to position the Overlay Window. |
| **Font Matcher** | Logic that reads the target text field's font family, size, and weight via Accessibility attributes to render ghost text that visually blends with the user's actual text. |
| **Accept** | User presses `Tab` to insert the full ghost text completion into the active text field. |
| **Partial Accept** | User presses the forward arrow key (→ for LTR, ← for RTL) to accept one word at a time in reading direction. |
| **Dismiss** | User presses `Esc` or continues typing — ghost text disappears. |
| **Cycle** | User presses `⌥↓`/`⌥↑` to rotate through alternative completions. |
| **Dormant Mode** | State when macOS Secure Input is active. Scribe Bar stops all reading, inference, and logging. Sleeping icon shown in menu bar. |
| **App Exclusion List** | A user-editable blocklist of apps where Scribe Bar never activates (password managers, banking apps, 2FA). Ships with sensible defaults. |
| **Secret Filter** | Pattern-matching layer that strips private keys, API tokens, credit card numbers, and high-entropy strings before data reaches the Writing Profile. |
| **Distribution** | Direct `.dmg` download + Homebrew Cask. No Mac App Store (sandbox blocks required Accessibility/ScreenCaptureKit APIs). Auto-updates via Sparkle. |
| **Trigger Delay** | Inference fires 400ms after the last keystroke (800ms on battery). Minimum 8 characters in the active field. Aborts in-flight inference if the user resumes typing. |
| **Prompt Assembly** | Chat/Instruct format. Layers: system prompt → Writing Profile excerpt → Screen Context → Clipboard Context → Typing Context → model generates. FIM reserved for v2. |

## Design Principles

1. **Privacy by confinement** — Personalization data exists but is strictly confined to the device. Zero network transmission of user data. No Sentry. No third-party SDKs that phone home. The Network Boundary is a hard architectural rule.
2. **Fully auditable** — All stored data is plaintext JSON, user-inspectable, and user-deletable. No opaque encrypted databases. If you can't `cat` it, we don't store it.
3. **Bilingual-native** — Arabic and English are first-class citizens at the model selection and prompt engineering level, not bolted on via a user prompt string.
4. **Open source** — MIT licensed. Free forever. The codebase is public and auditable.
