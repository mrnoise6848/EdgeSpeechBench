# Procedure
1. Validate configuration and input; hash and normalize before timing.
2. Capture app footprint baseline.
3. Fresh provider: timed load → timed initialization → timed first file inference.
4. Execute configured warmups (default 2), excluded from warm statistics.
5. Execute measured file sessions (default 5), sequentially with monotonic clock.
6. Capture endpoint footprint and stop sampler; unload provider.
7. Compute statistics/RTF; save only after measurement.

Progress reports the actual step being executed, not an invented percentage.
Apple system cache residency cannot be controlled. Warm measurements include new
analyzer session preparation, file decoding, inference and final result collection.
Cold load/init boundaries do not isolate internal Apple model operations. Background
OS activity, thermal state, debug builds and simulator execution affect results.

## Repeatability
Store all 2–20 warm session latencies, input SHA-256, decoded duration, normalized
sample rate/channels, configuration, OS/hardware and app version. Repeat by using
the same bundled fixture/preset/warmup/repetition counts. Median is the central
metric; mean, nearest-rank p95, min/max and sample standard deviation are available.
With five runs p95 equals max and is not a robust tail-latency estimate.
