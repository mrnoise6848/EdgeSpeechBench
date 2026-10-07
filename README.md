# EdgeSpeechBench

**How fast does speech AI run on this iPhone?**

A transcript answers what was said. Choosing an on-device speech workflow also requires knowing the cost: initialization, repeated processing time, memory footprint and variation between runs.

EdgeSpeechBench is an iOS measurement lab for Apple's SpeechTranscriber. It runs reproducible audio fixtures, separates cold-provider costs from warm file sessions, and saves enough input and device context to compare exported results.

## Define the experiment before reading the number

```text
Prepare audio and install model assets outside the measured run
    → fresh provider: load → initialize → first inference
    → 2 excluded warmups by default
    → 5 measured file sessions by default
    → statistics, device context and optional fixture WER
```

Each warm session includes analyzer preparation, audio decoding, inference and finalization. The benchmark answers a file-processing question rather than isolating a neural-network kernel. System caches cannot be flushed, so **provider-cold does not mean OS-cold**.

| Question | Recorded evidence |
|---|---|
| What does the first use cost? | Load, preparation, first inference and cold total |
| How repeatable are later sessions? | Median, mean, min/max, nearest-rank p95 and sample standard deviation |
| Can processing keep pace with the file? | Real-time factor: warm median / decoded audio duration |
| What does the app's memory footprint look like? | Baseline, 100 ms sampled peak and endpoint |
| Was this the same experiment? | Input SHA-256, audio format/duration, configuration, device/OS/build and thermal context |
| How did transcription match a reference? | Optional fixture word error rate |

Memory covers the app process, not total system/model memory. A sampled peak can miss short spikes. Five runs and a small fixture corpus are useful for inspecting behavior, not establishing population-wide latency or speech accuracy. [Methodology](docs/benchmark-methodology.md) · [Metrics](docs/metrics.md) · [Memory](docs/memory-measurement.md)

## Configure, run, compare

<p align="center">
  <img src="docs/images/benchmark-screen.png" width="360" alt="EdgeSpeechBench simulator showing the audio fixture, timeout, warmup count and measured-run count">
</p>

*Existing simulator capture of the experiment configuration, before a run.*

Open `EdgeSpeechBench.xcodeproj` with the compatible Xcode toolchain; the target is iOS 26.5. Configure device signing, install English assets using the separate action, select a fixture and run. History supports reviewing and comparing saved runs; reports export as JSON, CSV or text.

Three bundled fixtures use a JFK excerpt, repetition and reduced amplitude. Keep the device, Release build, settings and thermal conditions comparable. [Fixture provenance](docs/audio-samples.md) documents the audio. Standard and alternatives presets configure the same Apple en-US model; they are not separate model families.

## A harness that can be tested without the model

The `BenchmarkRunner` actor coordinates normalization, inference and memory sampling through a `SpeechModel` boundary. It emits progress and returns an immutable result after cleanup. SwiftData persistence and SwiftUI presentation sit outside the runner, allowing orchestration tests to use a test provider.

Cancellation and errors stop sampling and unload the provider. Local SwiftData history stores versioned run snapshots with CloudKit disabled. [Runner](EdgeSpeechBench/Benchmark/BenchmarkRunner.swift) · [Architecture](docs/architecture.md) · [Design decisions](docs/decisions/)

## Verification and results

The [verification record](docs/verification.md) reports successful Release static analysis and a simulator suite with **11 passes and one real-model integration skip**. Coverage includes statistics, normalization, persistence, report export, deadlines and cancellation.

**Physical-iPhone benchmark results are still pending.** Test-provider timings establish harness behavior; the next evidence is a signed-device run with exported latency, RTF, memory and WER results. No synthetic performance numbers are presented as device results.

Benchmarking uses installed local assets. Asset installation can download Apple's model; there is no audio/transcript upload or analytics integration. Reports export metadata rather than audio or transcript content. Runtime support, exact hardware placement and unavailable model metadata are documented in [limitations](docs/limitations.md) and [privacy](docs/privacy.md).
