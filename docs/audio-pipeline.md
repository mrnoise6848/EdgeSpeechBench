# Audio pipeline
Bundled fixed PCM WAV or a security-scoped local import → validate mono/stereo,
8–192 kHz and duration ≤180 seconds → SHA-256 content identity → AVAudioConverter
mono Float32 at the runtime's preferred rate → cached CAF → inference.
Conversion and hashing use bounded buffers off the UI actor. Cache holds at most
four normalized files. Normalization finishes before timed model setup/inference.
Missing/corrupt/unsupported audio throws an actionable error. No microphone is used.
Imported audio remains in the app sandbox; result deletion does not delete imports.
