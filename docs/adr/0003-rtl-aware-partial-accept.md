# ADR-0003: RTL-aware partial completion acceptance

## Status
Accepted

## Context
Scribe Bar is bilingual-native (Arabic + English). Partial accept — consuming a completion word-by-word — must follow the user's reading direction. In English (LTR), words are accepted left-to-right. In Arabic (RTL), words must be accepted right-to-left.

Cotypist uses a configurable shortcut for partial accept but does not appear to handle RTL direction natively — it likely treats Arabic as LTR, which feels unnatural.

## Decision
Use **direction-aware arrow keys** for partial accept:

| Action | LTR (English) | RTL (Arabic) |
|---|---|---|
| Accept full | `Tab` | `Tab` |
| Accept next word | `→` (right arrow) | `←` (left arrow) |
| Dismiss | `Esc` / keep typing | `Esc` / keep typing |
| Cycle alternatives | `⌥↓` / `⌥↑` | `⌥↓` / `⌥↑` |

### Direction detection
- Primary signal: the `NSWritingDirection` attribute of the focused text field via Accessibility
- Fallback: detect from the ghost text content itself using `NLLanguageRecognizer` — if the completion is Arabic script, treat as RTL

### Overlay rendering
- For RTL completions, the ghost text is rendered extending **leftward** from the cursor position
- The Overlay Window's text alignment flips accordingly

## Consequences
- **Good**: Arabic users get a natural word-by-word accept flow that follows reading direction
- **Good**: Differentiator vs. Cotypist and most other autocomplete tools
- **Good**: Arrow key choice is intuitive — "forward" always means "in reading direction"
- **Trade-off**: Mixed-direction text (Arabic sentence with English word mid-sentence) needs careful handling at word boundaries
- **Trade-off**: Must detect writing direction per-field, not per-app (some apps have both LTR and RTL fields)
