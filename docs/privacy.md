# Privacy
No accounts, analytics, cloud backend, CloudKit entitlements or remote ASR calls.
Audio normalization and transcription occur locally. Apple manages on-device speech
assets; the explicit Install action may contact Apple to download assets. Benchmark
execution requires installed assets and does not initiate an asset download.
Audio, transcript, benchmark metadata and device identifiers are not uploaded by
this app. Device context excludes personal device name, serial number and IDFV.
Persisted/exported records contain metrics/metadata only; no transcript, audio,
file URL or reference text. SHA-256 identifies the benchmark input content.
Imported files are sandbox-local and survive result deletion. Uninstalling removes
app-local data. User-invoked Files export may target a location chosen by the user.
