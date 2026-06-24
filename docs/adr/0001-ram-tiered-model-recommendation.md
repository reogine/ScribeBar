# ADR-0001: RAM-tiered model recommendation with language-aware filtering

## Status
Accepted

## Context
Scribe Bar needs to recommend an appropriate AI model during first-launch setup. Users' Macs range from 8 GB base M1 MacBook Air to 192 GB M4 Ultra Mac Studio. A model too large will choke the system; a model too small wastes the hardware. Cotypist ships a single default (Gemma 3 1B) regardless of hardware, which is suboptimal for capable machines.

Additionally, Scribe Bar is bilingual-native (Arabic + English). Not all model families handle Arabic equally — Qwen 3 has significantly stronger Arabic training data than Gemma 3.

## Decision
Use a **RAM-tiered recommendation system** with **language-aware model filtering**:

### Tier mapping (based on total physical RAM)

| Tier | RAM | Max model size | English-first pick | Arabic-capable pick |
|---|---|---|---|---|
| Lite | 8 GB | ≤ 1.5 GB | Gemma 3 1B | Qwen 3 0.6B |
| Standard | 16 GB | ≤ 3 GB | Gemma 3 4B | Qwen 3 1.7B |
| Power | 24+ GB | ≤ 5 GB | Gemma 4 E4B | Qwen 3 4B |
| Ultra | 48+ GB | ≤ 18 GB | Gemma 4 26B A4B | Qwen 3 30B A3B |

### Rules
- Model budget is **≤ 25% of total RAM** to leave headroom for OS and apps
- Language preference (selected during setup) determines which model family is preferred within the tier
- Free disk space must be ≥ 2× model size before download begins (download + extraction headroom)
- User can always override the recommendation and pick any model from the catalog

### Hardware detection
- Chip/model: `sysctl hw.model` + IOKit
- RAM: `ProcessInfo.processInfo.physicalMemory`
- GPU cores: Metal device query via IOKit
- Free disk: `FileManager` volume capacity stats

## Consequences
- **Good**: Users always get the best model their Mac can handle, not a one-size-fits-all default
- **Good**: Arabic users get a genuinely capable model, not a bolted-on prompt hack
- **Good**: 8 GB machines aren't offered models that will freeze their system
- **Trade-off**: We must maintain and test multiple models across tiers, increasing CI/QA surface
- **Trade-off**: Model catalog updates require updating the tier mapping table
