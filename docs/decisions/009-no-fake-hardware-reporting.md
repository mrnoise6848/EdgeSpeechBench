# Execution configuration
SpeechAnalyzer owns execution configuration. It does not expose selectable Core ML
compute units or reliable per-inference CPU/GPU/ANE placement. Display System
managed; hardware execution unavailable. The UI offers transcription presets,
not fake compute-unit switches. Future Core ML providers can expose configured
units separately from observed hardware evidence.
