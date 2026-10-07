# Optional WER
Uses the last measured warm transcript and manually supplied bundled reference.
Lowercase, split on non-alphanumeric characters, drop empty words. Levenshtein
word edits / reference word count; insertions can make WER >100%. No special
number expansion, contraction repair, stemming or language-aware normalization.
Imports without ground truth report Not available. Transcript text is transient
and is not persisted/exported. This small JFK corpus is not a general accuracy test.
