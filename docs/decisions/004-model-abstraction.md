# Model boundary
SpeechModel is an actor protocol. Providers own load, runtime initialization,
transcription, format negotiation and cleanup. The runner accepts any provider,
including test providers, with no knowledge of SpeechAnalyzer or persistence.
The two Apple presets are configurations of the same model, not different models.
