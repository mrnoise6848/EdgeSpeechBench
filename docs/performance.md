# Resource safety
Audio import limits: regular files ≤100 MB; mono/stereo; decoded duration ≤180 s.
Conversion/hash use bounded buffers. Normalized cache ≤4 entries and stale files
are cleaned on first preparation after launch. Measured latency history ≤20 samples.
Memory sampling stores only max, at 10 Hz. UI progress changes only at step boundaries;
there are no fake percentages, animated charts, tensor dumps or per-frame logs.
SwiftData writes and exports happen after inference. History fetch caps at latest
200 runs to keep UI work bounded. Background OS processes remain uncontrolled.
