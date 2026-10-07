# Real inference integration
Uses Apple SpeechTranscriber (en-US) via SpeechAnalyzer, part of the existing iOS
26.5 SDK. No open-source runtime code is copied, no package is added, and no model
is trained/converted. Apple's proprietary prepared assets and OS framework license
apply. AssetInventory download is an explicit setup action, outside timed runs.
Benchmarks fail when assets are absent; audio is never sent to a remote ASR API.

Each file session collects finalized text through the results async sequence and
waits for analyzer finalization. Finished sessions require a new analyzer; warm
latency includes session creation/preparation and file decoding. .lingering requests
model residency across sessions, but system caches are outside app control.

References:
https://developer.apple.com/documentation/speech/speechanalyzer
https://developer.apple.com/documentation/speech/speechtranscriber
https://developer.apple.com/documentation/speech/assetinventory
