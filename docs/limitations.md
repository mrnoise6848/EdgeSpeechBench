# Limitations
- Physical compatible Apple hardware and preinstalled en-US speech assets are
  required for real model runs; simulators may not support SpeechTranscriber.
- Apple does not expose model version/size, hardware placement, service/model
  memory, or guaranteed cache eviction. Provider-cold is not OS-cold.
- Timings measure wall-clock file sessions, not isolated neural-network kernels.
- .lingering requests residency but does not guarantee identical system caches.
- Small repeated samples and one speaker do not establish a universal winner or
  production accuracy. WER preprocessing is deliberately simple.
- Debug/simulator runs are unsuitable for iPhone performance claims. Use release
  on physical hardware, same conditions, cool device and stable foreground state.
- 100 ms memory sampling may miss spikes; extreme OS memory termination cannot
  be caught. Cancellation relies on framework responsiveness.
- Imports: ≤100 MB, ≤180 seconds, 1–2 channels, 8–192 kHz. History shows latest
  200 runs. Imported files remain sandboxed across launches but the picker lists
  this session's imports only. App uninstall deletes local storage.
- No microphone, selectable Core ML compute units, or additional independent
  ASR model provider is implemented; the presets use the same Apple model.
