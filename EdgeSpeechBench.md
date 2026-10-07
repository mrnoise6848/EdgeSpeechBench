# EdgeSpeechBench — Final Swift Technical Showcase Specification & Agent Instructions

## 1. PROJECT GOAL

Build a **small, technically deep iOS on-device speech benchmark showcase**.

This is NOT a normal speech-to-text application.

The core goal is:

> **Measure and explain how efficiently a speech-to-text model actually runs on an iPhone.**

The project should demonstrate:

* Swift
* SwiftUI
* SwiftData
* on-device ML inference
* Core ML / appropriate Apple on-device ML APIs
* AVFoundation audio handling
* inference benchmarking
* cold-start vs warm-run measurement
* latency measurement
* real-time factor measurement
* memory measurement where available
* compute-unit/backend reporting where available
* reproducible benchmark runs
* clean technical architecture

---

# 2. CRITICAL EXECUTION RULES

You are implementing an **EXISTING iOS project**.

The existing source code, project structure, architecture, Xcode configuration, Swift version, deployment target, package dependencies, and build environment are considered valid.

Your job is to **extend the existing project**, not recreate or migrate it.

## NON-NEGOTIABLE RULES

1. **Do NOT recreate the project from scratch.**
2. **Work directly on the existing source code.**
3. This project is **Swift + SwiftUI + SwiftData**.
4. **Use SwiftData for local persistence.**
5. **Do NOT use Core Data unless the existing project already requires it and there is a strong technical reason.**
6. **Do NOT enable CloudKit.**
7. **Do NOT use CloudKit for this project.**
8. **Do NOT add CloudKit containers or synchronization.**
9. The benchmark engine must work independently of persistence.
10. SwiftData is only for storing benchmark metadata/results.
11. **Do NOT change the existing Swift version unnecessarily.**
12. **Do NOT change the iOS deployment target unnecessarily.**
13. **Do NOT change existing Xcode/project configuration unnecessarily.**
14. **Do NOT upgrade or downgrade dependencies simply because newer versions exist.**
15. **Do NOT replace the existing architecture unnecessarily.**
16. **Do NOT change package/bundle identifiers unnecessarily.**
17. **Do NOT perform broad refactors unrelated to EdgeSpeechBench.**
18. **Do NOT remove working functionality.**
19. Reuse existing project infrastructure whenever possible.
20. You are explicitly allowed to use mature **open-source projects, Swift packages, Core ML resources, Apple sample code, model implementations, and existing inference libraries** when they reduce unnecessary work or improve correctness.
21. Before using external code, inspect:

    * license
    * compatibility
    * maintenance quality
    * security implications
    * model license where relevant
22. Do not blindly copy large sections of another repository.
23. Prefer mature inference/model implementations over implementing a speech recognition runtime from scratch.
24. **Do NOT introduce unnecessary packages.**
25. **Do NOT build a custom ML inference engine unless absolutely necessary.**
26. **Do NOT use fake benchmark results.**
27. **Do NOT hardcode latency, memory, RTF, CPU/GPU/ANE, throughput, or accuracy values.**
28. Every displayed benchmark value must come from an actual measurement or be explicitly marked unavailable.
29. **Do NOT run tests until ALL implementation phases are complete.**
30. **Commit after every completed phase.**
31. Optimize token/compute usage without sacrificing correctness or implementation quality.

---

# 3. PRODUCT TYPE

EdgeSpeechBench is a:

> **Developer-focused on-device speech inference benchmark and profiling tool.**

It is NOT:

* Siri
* a dictation app
* a voice assistant
* a transcription SaaS
* a cloud speech API client
* a consumer note-taking app
* a complete speech platform

The benchmark/reporting system is the core product.

---

# 4. CORE QUESTION

The project should answer questions such as:

> Which model is faster on this device?

> How much does cold start cost?

> How fast is warm inference?

> Can the model process speech faster than realtime?

> How much memory does the inference process use?

> Which execution backend/configuration performs best?

---

# 5. CORE PIPELINE

```text
Audio Input
    ↓
Audio Normalization
    ↓
Model Preparation
    ↓
Inference
    ↓
Measurement
    ↓
Metrics
    ↓
Benchmark Result
    ↓
SwiftData Persistence
    ↓
Comparison / Report
```

---

# 6. TECHNOLOGY

Primary stack:

```text
Swift
SwiftUI
SwiftData
AVFoundation
Core ML / appropriate Apple on-device ML APIs
```

Use the current project's existing compatible APIs and libraries.

Do not change the project's toolchain merely to use a newer API.

---

# 7. CLOUDKIT RULE

## CLOUDKIT MUST NOT BE USED

Do NOT:

* enable CloudKit
* create CloudKit containers
* configure iCloud synchronization
* add CloudKit entitlements
* sync benchmark results to the cloud

This project is designed as a local benchmark tool.

All benchmark results remain local unless the user explicitly exports them.

---

# 8. PHASE 1 — EXISTING PROJECT INSPECTION

Inspect the existing project.

Review:

* project tree
* Xcode configuration
* Swift version
* iOS deployment target
* SwiftUI setup
* SwiftData setup
* package dependencies
* architecture
* existing services
* existing audio code
* existing persistence
* entitlements
* capabilities
* signing-related configuration
* existing tests
* reusable components

Do not change foundational configuration.

Create/update:

```text
docs/architecture.md
```

Document:

* current architecture
* benchmark architecture
* inference boundary
* audio pipeline
* persistence
* metric collection
* external model/library strategy

### Commit after completion.

---

# 9. PHASE 2 — DOMAIN MODEL

Create platform-independent benchmark models where practical.

Conceptually:

```text
BenchmarkRun
BenchmarkConfiguration
ModelConfiguration
AudioSample
InferenceResult
MetricSnapshot
BenchmarkSummary
PerformanceComparison
```

Useful metrics:

```text
modelName
modelVersion
audioDuration
loadTime
coldStartTime
warmInferenceTime
totalInferenceTime
realTimeFactor
memoryUsage
backend
computeUnit
success
error
timestamp
```

Keep domain logic separate from SwiftData persistence models where useful.

The benchmark engine must not depend directly on SwiftData.

### Commit after completion.

---

# 10. PHASE 3 — AUDIO INPUT

Implement a controlled audio input pipeline.

Support:

* bundled benchmark audio samples
* local audio import where practical
* optional microphone recording if it materially improves the benchmark

The benchmark should be reproducible.

Therefore:

> **Bundled fixed benchmark samples are required.**

Example:

```text
Sample A
30 seconds
English speech

Sample B
60 seconds
English speech

Sample C
mixed speech conditions
```

Do not rely only on microphone recordings because they make reproducibility difficult.

Handle:

* unsupported format
* corrupt audio
* missing file
* invalid sample rate
* unsupported channel count
* insufficient permissions where microphone input is used

### Commit after completion.

---

# 11. PHASE 4 — AUDIO NORMALIZATION

Normalize input audio to the format required by the selected model.

Handle:

* sample rate
* channel count
* PCM format
* duration
* buffering

Do not repeatedly resample the same audio unnecessarily.

Cache normalized benchmark inputs where useful.

Do not load huge audio files entirely into memory when avoidable.

### Commit after completion.

---

# 12. PHASE 5 — MODEL INTEGRATION

Integrate at least one real on-device speech-to-text model.

Prefer an existing mature implementation or model package.

Examples may include:

* Core ML compatible speech models
* Whisper-based Core ML implementations
* Parakeet/Core ML speech models
* another mature on-device ASR implementation compatible with the project

Do NOT implement a speech model from scratch.

Do NOT train a model.

Do NOT build a model conversion pipeline inside the app unless genuinely required.

The app should consume an already prepared model/runtime.

### Commit after completion.

---

# 13. PHASE 6 — MODEL ABSTRACTION

Create a model provider abstraction.

Conceptually:

```text
SpeechModel
    ↓
load()
transcribe()
unload()
metadata()
```

Allow different model implementations to be compared.

Example:

```text
Model A
Model B
Model C
```

The benchmark engine should not contain model-specific logic.

### Commit after completion.

---

# 14. PHASE 7 — MODEL METADATA

Display:

* model name
* model version
* model size where available
* supported language
* expected input format
* execution configuration

Example:

```text
Parakeet
Version 0.x

Model Size
...

Language
English
```

Do not invent metadata.

Where unavailable:

```text
Not available
```

### Commit after completion.

---

# 15. PHASE 8 — COLD START BENCHMARK

Measure cold-start behavior.

Possible phases:

```text
App / Model not loaded
        ↓
Load model
        ↓
Initialize runtime
        ↓
First inference
```

Measure separately:

* model load time
* initialization time
* first inference latency
* total cold-start time

Do not mix model loading and inference into a single unexplained number.

### Commit after completion.

---

# 16. PHASE 9 — WARM INFERENCE BENCHMARK

After initialization, execute multiple inference runs.

Measure:

* inference duration
* average
* median
* p95 where practical
* min/max
* total inference time

Do not report a single noisy sample as a definitive result.

Use repeated controlled runs.

### Commit after completion.

---

# 17. PHASE 10 — REAL-TIME FACTOR

Calculate:

```text
RTF = inference time / audio duration
```

Interpretation:

```text
RTF < 1
→ faster than realtime

RTF = 1
→ realtime

RTF > 1
→ slower than realtime
```

Example:

```text
Audio
60 seconds

Inference
18 seconds

RTF
0.30x
```

The app must calculate this from real measured values.

### Commit after completion.

---

# 18. PHASE 11 — MEMORY MEASUREMENT

Where iOS APIs permit meaningful application-level measurement, measure memory behavior.

Possible values:

* memory before load
* peak memory during inference
* memory after inference
* delta

Be explicit about what is measured.

For example:

```text
Peak app memory
```

is not necessarily:

```text
Model-only memory
```

Do not pretend to isolate memory that the platform does not expose reliably.

Where unavailable:

```text
Not available
```

### Commit after completion.

---

# 19. PHASE 12 — COMPUTE BACKEND / CONFIGURATION

Where supported by the model/runtime:

Show:

* CPU
* GPU
* Neural Engine / ANE
* mixed/automatic configuration

Do not claim that a model definitely ran on a specific hardware block unless the selected framework/runtime exposes reliable evidence.

If exact hardware execution cannot be proven:

```text
Configured compute units:
CPU + GPU + Neural Engine
```

rather than:

```text
Definitely executed on ANE
```

### Commit after completion.

---

# 20. PHASE 13 — BENCHMARK RUNNER

Create a reusable benchmark runner.

Input:

```text
Model
+
Audio Sample
+
Configuration
```

Output:

```text
BenchmarkResult
```

The runner should handle:

* setup
* warmup
* measurement
* repetitions
* cleanup
* result generation
* cancellation
* errors

Do not put benchmark logic inside SwiftUI views.

### Commit after completion.

---

# 21. PHASE 14 — WARMUP STRATEGY

Clearly distinguish:

```text
Cold Run
Warmup
Measured Warm Runs
```

Do not accidentally include initialization overhead in warm inference measurements.

Document the benchmark procedure.

Example:

```text
Cold Run: 1
Warmup Runs: 2
Measured Runs: 5
```

### Commit after completion.

---

# 22. PHASE 15 — BENCHMARK REPEATABILITY

Run the same benchmark configuration multiple times.

Calculate:

* median
* average
* p95 where useful
* standard deviation where useful

Use stable benchmark inputs.

Avoid random audio by default.

Do not compare results generated under obviously different conditions without labeling them.

### Commit after completion.

---

# 23. PHASE 16 — DEVICE INFORMATION

Store useful device context.

Possible information:

* device model
* iOS version
* processor/device family where available
* app build version
* model configuration

Do not collect unnecessary personal data.

Example:

```text
Device
iPhone XX

iOS
XX.X

Model
Parakeet
```

### Commit after completion.

---

# 24. PHASE 17 — BENCHMARK COMPARISON

Allow users to compare benchmark runs.

Example:

```text
Model A
RTF
0.32x

Model B
RTF
0.51x

Model A
Memory
1.2 GB

Model B
Memory
0.9 GB
```

Highlight actual measured differences.

Do not declare a universal winner.

Say:

> Faster on this device/configuration.

### Commit after completion.

---

# 25. PHASE 18 — RESULT PERSISTENCE WITH SWIFTDATA

Persist benchmark results locally using **SwiftData**.

Example models:

```text
BenchmarkRunRecord
ModelRecord
MetricRecord
DeviceRecord
```

Store only useful benchmark information.

SwiftData is persistence only.

The benchmark engine must remain independently executable without SwiftData.

### IMPORTANT

Do NOT enable:

* CloudKit
* iCloud sync
* Cloud containers

### Commit after completion.

---

# 26. PHASE 19 — HISTORY UI

Show previous benchmark runs.

Example:

```text
Benchmark History

Parakeet
iPhone XX
RTF 0.31x
Today

Whisper
iPhone XX
RTF 0.48x
Yesterday
```

Allow:

* open result
* compare
* delete result

### Commit after completion.

---

# 27. PHASE 20 — LIVE BENCHMARK UI

Create a clean SwiftUI benchmark screen.

Example:

```text
EdgeSpeechBench

Model
Parakeet

Audio
60 sec

Status
Running

Warmup
2 / 2

Inference
3 / 5
```

After completion:

```text
RTF
0.31x

Median
18.4 sec

Peak Memory
1.2 GB
```

No fake progress.

Progress must correspond to actual benchmark steps.

### Commit after completion.

---

# 28. PHASE 21 — RESULT DETAIL

Show:

```text
Benchmark Result

Model
Parakeet

Audio
60 sec

Cold Start
1.82 sec

Median Warm Inference
18.4 sec

RTF
0.31x

Peak Memory
1.2 GB

Compute Configuration
Automatic
```

Include a clear note about measurement methodology.

### Commit after completion.

---

# 29. PHASE 22 — EXPORT

Allow exporting benchmark results as a simple JSON or CSV report.

Example:

```text
{
  "model": "...",
  "audioDuration": 60,
  "coldStart": 1.82,
  "medianInference": 18.4,
  "rtf": 0.31
}
```

Exported results must contain only benchmark metadata.

Do not export private audio unless explicitly selected.

### Commit after completion.

---

# 30. PHASE 23 — BENCHMARK REPORT

Create a readable benchmark report.

Example:

```text
Model:
Parakeet

Device:
iPhone XX

Audio:
60 seconds

Cold Start:
1.82s

Warm Median:
18.4s

RTF:
0.31x

Peak App Memory:
1.2 GB

Runs:
5
```

The report should clearly state:

* model
* device
* OS
* audio duration
* run count
* methodology
* limitations

### Commit after completion.

---

# 31. PHASE 24 — OPTIONAL ACCURACY EVALUATION

Where a ground-truth transcript is available for a bundled sample, optionally calculate a basic accuracy metric such as WER.

This is optional but highly valuable.

Example:

```text
Ground Truth
↓
Reference Transcript

Model Output
↓
Recognized Transcript

WER
8.4%
```

The benchmark should then become:

```text
Speed
+
Memory
+
Accuracy
```

Do not claim production-grade speech accuracy.

Document preprocessing and scoring methodology.

### Commit after completion.

---

# 32. PHASE 25 — THERMAL / REPEATABILITY NOTES

Where the platform exposes useful information, record repeated-run behavior.

Do not claim exact thermal throttling metrics unless reliable APIs are available.

A useful benchmark note may be:

```text
Repeated runs became slower after sustained inference.
```

when this is actually observed.

Do not invent thermal measurements.

### Commit after completion.

---

# 33. PHASE 26 — PERFORMANCE / RESOURCE SAFETY

The benchmark tool itself must not distort the measurements unnecessarily.

Avoid:

* excessive SwiftUI updates
* excessive disk writes during inference
* unnecessary logging
* storing every intermediate tensor
* unbounded metric history
* unnecessary JSON conversion
* repeated model loading
* background work that competes with inference

Benchmark data collection should be lightweight.

### Commit after completion.

---

# 34. PHASE 27 — PRIVACY

The project should be local-first.

Do not upload:

* audio
* transcriptions
* benchmark results
* device identifiers
* private data

to remote services.

Do not require an account.

Do not use CloudKit.

Avoid analytics that expose benchmark/audio information.

### Commit after completion.

---

# 35. PHASE 28 — ERROR HANDLING

Handle:

* model loading failure
* unsupported model
* invalid audio
* memory pressure
* inference failure
* unsupported compute configuration
* insufficient device resources
* permission denial if microphone input is used
* benchmark cancellation
* persistence failure
* export failure

Do not crash the application because one benchmark run fails.

Example:

```text
Benchmark failed

Reason:
Model could not be initialized on this device.
```

### Commit after completion.

---

# 36. PHASE 29 — UI / UX POLISH

The UI should feel like a professional developer tool.

Requirements:

* clean
* modern
* technical
* readable
* fast
* trustworthy

Avoid:

* excessive animations
* unnecessary cards
* fake graphs
* decorative UI that adds no value
* unexplained technical jargon

The primary actions should be:

```text
Choose Model
Choose Sample
Run Benchmark
Compare
View History
Export
```

### Commit after completion.

---

# 37. PHASE 30 — DOCUMENTATION

Create/update:

```text
docs/architecture.md
docs/audio-pipeline.md
docs/inference.md
docs/benchmark-methodology.md
docs/metrics.md
docs/memory-measurement.md
docs/swiftdata.md
docs/privacy.md
docs/performance.md
docs/limitations.md
docs/decisions/
```

Suggested decisions:

```text
001-preserve-existing-project.md
002-swiftdata-local-persistence.md
003-no-cloudkit.md
004-model-abstraction.md
005-benchmark-methodology.md
006-cold-vs-warm-measurement.md
007-rtf-definition.md
008-memory-measurement.md
009-no-fake-hardware-reporting.md
010-reproducible-audio-samples.md
```

### Commit after completion.

---

# 38. PHASE 31 — README / PORTFOLIO PRESENTATION

README must immediately communicate the engineering value.

Recommended:

```text
# EdgeSpeechBench

How fast does speech AI actually run on an iPhone?

EdgeSpeechBench is a local iOS benchmark tool for
measuring on-device speech inference performance.

It measures:

- cold-start latency
- warm inference latency
- real-time factor
- memory behavior
- compute configuration
- repeatability
- optional WER
```

Then:

```text
## Problem

## Architecture

## Benchmark Methodology

## Metrics

## Example Results

## Models

## Swift / SwiftUI

## SwiftData

## On-device Inference

## Reproducibility

## Privacy

## Limitations

## Roadmap
```

Add screenshots and a concise benchmark example.

Do not claim measurements that were not actually produced.

### Commit after completion.

---

# 39. PHASE 32 — FINAL STATIC REVIEW

After all implementation work:

Review everything without running tests yet.

Check:

* Swift concurrency
* actor isolation where applicable
* audio lifecycle
* model lifecycle
* memory retention
* benchmark contamination
* unnecessary SwiftUI updates
* SwiftData usage
* no CloudKit configuration
* no secrets
* no fake results
* no fake metrics
* no debug code
* package dependencies
* documentation accuracy

### Commit after completion.

---

# 40. CONTINUOUS IMPLEMENTATION REQUIREMENT

After implementation starts:

> **Continue automatically through ALL implementation phases until Phase 32 is complete.**

Do not stop after planning.

Do not wait for user confirmation.

Do not ask for approval between phases.

Move directly to the next phase.

If a genuine blocker occurs:

1. inspect the existing project
2. inspect current dependencies
3. inspect Apple APIs
4. inspect compatible model/runtime implementations
5. inspect mature open-source projects
6. choose the least invasive compatible solution
7. document the limitation

Do not silently change foundational project configuration.

---

# 41. TESTING RULE

## DO NOT RUN TESTS UNTIL ALL IMPLEMENTATION PHASES ARE COMPLETE

During Phases 1–32:

Do NOT execute:

* unit tests
* UI tests
* integration tests
* benchmark tests
* performance tests
* snapshot tests
* full Xcode test suites

You may:

* inspect tests
* create tests
* modify tests
* review tests statically

But:

> **DO NOT EXECUTE ANY TESTS UNTIL ALL IMPLEMENTATION PHASES ARE COMPLETE.**

This is intentional to save token/compute usage and avoid repeatedly testing incomplete intermediate states.

---

# 42. FINAL VERIFICATION — ONLY AFTER ALL PHASES

Only after Phase 32 is complete and all phase commits exist:

Perform the final verification.

Run:

* unit tests
* SwiftUI/UI tests
* SwiftData tests
* model integration tests
* benchmark harness tests
* static analysis
* build verification
* iOS simulator/device verification where available

Do not change toolchain versions merely to make verification pass.

---

# 43. FINAL BENCHMARK VALIDATION

After implementation is complete, run real benchmark sessions.

Verify:

1. Model load
2. Cold start measurement
3. Warmup
4. Warm inference
5. repeated runs
6. RTF calculation
7. memory measurement
8. compute configuration reporting
9. result persistence
10. comparison
11. history
12. export
13. benchmark cancellation
14. invalid audio
15. model failure
16. low-resource behavior
17. optional WER
18. reproducibility using fixed bundled samples

Only report measurements that were actually produced.

---

# 44. DEFINITION OF DONE

EdgeSpeechBench is complete when:

* existing iOS project preserved
* Swift is used
* SwiftUI is used
* SwiftData is used for local persistence
* CloudKit is NOT used
* no CloudKit container/configuration exists
* existing project versions/configuration are preserved
* model abstraction works
* real on-device speech model works
* fixed benchmark samples exist
* audio normalization works
* cold-start measurement works
* warm inference measurement works
* repeated runs work
* RTF is calculated correctly
* memory reporting works where supported
* compute configuration reporting is honest
* device information is recorded appropriately
* benchmark comparison works
* history works
* local persistence works
* export works
* optional WER works where implemented
* errors are handled safely
* benchmark engine is independent from SwiftData
* no fake metrics exist
* no fake results exist
* no cloud upload exists
* documentation exists
* README exists
* every phase has a Git commit
* final verification passes

---

# 45. GIT COMMIT RULE

After every completed phase:

```text
Review
 ↓
Remove debug code
 ↓
Update documentation
 ↓
Review git diff
 ↓
Commit
```

Use meaningful commit messages such as:

```text
feat(bench): add benchmark domain model
feat(bench): add audio pipeline
feat(bench): add model abstraction
feat(bench): add cold-start measurement
feat(bench): add warm inference benchmark
feat(bench): add rtf calculation
feat(bench): add memory metrics
feat(bench): add swiftdata history
```

Do not create empty commits.

Do not combine unrelated phases.

---

# 46. TOKEN / COMPUTE EFFICIENCY

Optimize for low token and compute consumption.

* Do not reread the entire repository repeatedly.
* Inspect only relevant files.
* Reuse existing code and packages.
* Avoid unnecessary refactors.
* Avoid unnecessary dependencies.
* Do not run tests until the end.
* Do not repeatedly rebuild the project during implementation.
* Do not repeatedly reload models unnecessarily.
* Keep benchmark metadata lightweight.
* Avoid excessive UI updates.
* Avoid unnecessary explanations.

Do not sacrifice:

* measurement accuracy
* correctness
* reproducibility
* maintainability
* security
* performance

for token savings.

---

# 47. VERSION / CONFIGURATION PROTECTION

The current project configuration is valid.

Do NOT change unnecessarily:

```text
Swift version
Xcode/project configuration
iOS deployment target
package dependencies
bundle identifier
signing configuration
SwiftUI setup
SwiftData setup
```

Do NOT enable:

```text
CloudKit
iCloud sync
remote persistence
```

If a required model/runtime is incompatible with the current project:

1. inspect existing alternatives
2. inspect other compatible packages
3. inspect Apple APIs
4. inspect mature open-source implementations
5. choose the least invasive compatible solution

Do not silently change foundational configuration.

---

# 48. FINAL INSTRUCTION

Build **EdgeSpeechBench as a small, reproducible, technically deep iOS on-device AI benchmark tool**.

The project should demonstrate:

```text
Swift
+
SwiftUI
+
SwiftData
+
On-device AI
+
Speech inference
+
Performance measurement
+
Memory analysis
+
Reproducible benchmarking
```

The core pipeline is:

> **Audio → Inference → Measure → Compare → Report**

The most important principle is:

> **Never fabricate benchmark results or hardware execution claims.**

Every metric must come from an actual measurement or be explicitly marked unavailable.

Use mature existing model/runtime implementations whenever possible.

Do not build a speech recognition engine from scratch.

Do not use CloudKit.

Do not add a cloud backend.

Keep the project small enough to understand, but technically deep enough to demonstrate real engineering ability.

**Start implementation immediately.**

**Continue automatically through ALL implementation phases until Phase 32 is complete.**

**Commit after every completed phase.**

**DO NOT RUN ANY TESTS UNTIL ALL IMPLEMENTATION PHASES ARE COMPLETE.**

Optimize token/compute usage without sacrificing measurement accuracy, correctness, reproducibility, security, or code quality.
