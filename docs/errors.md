# Failure and cancellation
Invalid configuration/audio, absent assets, unavailable runtime, conversion errors,
critical thermal state, timed-out model operations and inference failure propagate
to an actionable UI error. Cancellation does not save partial results. Cleanup
stops memory sampling, cancels analyzer sessions and releases provider references.
Each load/initialize/inference operation has a configurable deadline (default 120 s).
Structured cancellation waits for framework cleanup; an unresponsive OS call may
delay it. OS termination under extreme memory pressure cannot be recovered in-app.
Storage/export failures are displayed without discarding the current result.
