# Architecture

## Existing project (Phase 1)
The existing Xcode 26.6 project contains SwiftUI, a SwiftData Item template,
unit and UI test targets, and filesystem-synchronized source groups. Swift language
mode is 5.0 with approachable concurrency and MainActor default isolation;
iOS deployment target is 26.5. Bundle ID is com.noise.EdgeSpeechBench. There
are no package dependencies, entitlements, audio services, or CloudKit containers.
Signing, deployment target, language mode and targets will be preserved. Item is
retained for compatibility with the existing local store.

The specification was accidentally registered as Swift source by the existing
working-tree change. Only its source membership/file type will be corrected.

## Benchmark design
Sendable domain values → audio actor → SpeechModel provider → benchmark actor →
immutable run → main-actor view model → local SwiftData record → history/report.
The runner never imports SwiftData. AVFoundation handles bounded file conversion.
SpeechAnalyzer/SpeechTranscriber use Apple's prepared on-device models; no third
party runtime or conversion pipeline is needed. Assets must already be installed
for benchmarking; explicit asset installation happens separately from measurements.

Metrics use monotonic wall clock, repeated end-to-end file inference, and sampled
app physical footprint. System-service model memory and exact CPU/GPU/ANE execution
are unavailable. A fresh provider does not guarantee a system-cache-cold model.
No tests are executed before Phase 32. Each completed phase has a separate commit.

## Final source map
- Domain/: Codable run/configuration, summaries, RTF, WER, comparison and exports.
- Audio/: fixed catalog, scoped import, bounded converter and cache.
- Inference/: actor protocol and Apple provider; no cloud speech API.
- Benchmark/: runner, deadlines, monotonic timing, app footprint and device/thermal context.
- Persistence/: local SwiftData adapter; errors surfaced to views.
- Views/: observable main-actor controller, history, comparison, detail/export/privacy.

New domain types explicitly opt out of default MainActor isolation; actor-owned
services isolate audio/model lifecycles. UI stores one immutable completed result.
Runtime warm sessions renew analyzers because finalized analyzers cannot restart.
The provider abstraction allows future independent models without runner changes.
