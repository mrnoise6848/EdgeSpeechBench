# Metrics
All durations are seconds from ContinuousClock. Load = asset-installed check and
analyzer construction; initialization = prepareToAnalyze; first inference = first
file session. Cold total includes their inter-phase overhead. Warm latencies include
new session preparation, decoding, inference and result collection. Stats: mean,
even/odd median, min/max, nearest-rank p95, sample stddev (n−1), total. RTF uses
warm median / decoded duration. Memory is app phys_footprint bytes; delta is endpoint
minus baseline. WER uses last warm transcript. Missing values stay null in JSON,
blank in CSV and Not available in UI. No exact hardware claims or invented metrics.
