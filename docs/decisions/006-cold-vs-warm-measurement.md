# Cold vs warm
Provider-cold means a fresh provider and fresh analyzer; system caches cannot be
flushed. Asset availability and analyzer construction are load time. Runtime
prepareToAnalyze is initialization. First file transcription is separately timed.
Cold total covers all three phases including inter-phase overhead. Asset download
and audio normalization are excluded. Never describe this as guaranteed OS-cold.
