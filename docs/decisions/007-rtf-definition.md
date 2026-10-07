# RTF
RTF = measured warm median latency / decoded audio duration. Per-run RTF may also
be calculated with the same denominator. Values below one are faster than realtime.
Zero/nonfinite duration is invalid; never substitute a guessed duration. Wall-clock
file-session latency includes session preparation/decoding in warm runs.
