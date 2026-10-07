# Implementation phases

Each phase has a distinct, nonempty commit; tests began after phase 32.

1. `2344dce docs(architecture): inspect existing project and benchmark boundaries`
2. `79ff22b feat(domain): add independent benchmark values and configuration`
3. `bc645d4 feat(audio): bundle reproducible speech fixtures and validate local imports`
4. `30de8f2 feat(audio): normalize bounded PCM inputs with content keyed cache`
5. `f68d9a4 feat(inference): integrate real on-device Apple speech model`
6. `d8dc2f7 feat(inference): define replaceable actor based model providers`
7. `29204a1 feat(metadata): display model information and unavailable fields honestly`
8. `97a205d feat(bench): measure provider cold load initialization and first inference`
9. `32e59e1 feat(bench): collect repeated warm latencies and nearest rank statistics`
10. `82f04aa feat(metrics): calculate real time factor from measured latency and duration`
11. `5fa1bad feat(metrics): sample app physical footprint with explicit limitations`
12. `caedd62 feat(metrics): report system managed compute without hardware claims`
13. `5dd41a7 feat(bench): orchestrate real measurements in persistence independent runner`
14. `c256c81 feat(bench): separate untimed warmups from cold and measured sessions`
15. `0f06803 feat(bench): record normalized input identity and repeatability statistics`
16. `56df25f feat(device): capture anonymous hardware OS and build context`
17. `6fb4847 feat(compare): compare measured runs with explicit condition differences`
18. `8c57ff8 feat(storage): persist versioned benchmark snapshots locally with SwiftData`
19. `9bd3a03 feat(history): browse delete and select persisted runs for comparison`
20. `950faa4 feat(ui): connect real benchmark progress controls and local import`
21. `92396dc feat(results): explain measured cold warm memory and RTF details`
22. `66730af feat(export): export benchmark metadata as safe JSON and CSV documents`
23. `03c8b85 feat(report): produce readable measured reports with methodology and limitations`
24. `5f819d4 feat(accuracy): score optional fixture word error rate after inference`
25. `6e6d965 feat(thermal): record coarse states and describe observed repetition trends`
26. `28daed6 perf(bench): bound imports cache history and measurement overhead`
27. `89dc932 feat(privacy): document local processing and explicit asset installation`
28. `a1b3ea6 fix(errors): enforce operation deadlines and cancellation cleanup`
29. `8bcb969 feat(ui): polish developer flow and preserve existing local item functionality`
30. `aee9d8e docs(bench): complete architecture methodology privacy and engineering decisions`
31. `fb101d0 docs(readme): present engineering value and reproducible benchmark workflow`
32. `20d7066 fix(review): complete phase 32 static lifecycle audit and verification coverage`
