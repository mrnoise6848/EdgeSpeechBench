# Local persistence
SwiftData stores BenchmarkRunRecord with UUID/date/name indexes and a versioned
Codable domain snapshot. Item remains in the schema to preserve the template store.
CloudKit database is explicitly .none; no cloud entitlements or containers exist.
Runner has no persistence import. Writes happen once after a successful benchmark,
never during inference. Save/delete failures roll back and are surfaced to the UI.
Corrupt/unsupported payloads are reported rather than silently turned into metrics.
Storage setup failure displays a recovery message rather than fatalError.
