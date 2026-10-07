import Foundation
import SwiftData

@Model
final class BenchmarkRunRecord {
    @Attribute(.unique) var runID: UUID
    var timestamp: Date
    var modelName: String
    var sampleName: String
    var payload: Data
    init(run: BenchmarkRun) throws {
        runID = run.id
        timestamp = run.timestamp
        modelName = run.model.name
        sampleName = run.sampleName
        payload = try JSONEncoder().encode(run)
    }
    func decode() throws -> BenchmarkRun {
        let run = try JSONDecoder().decode(BenchmarkRun.self, from: payload)
        guard run.schemaVersion == 1 else {
            throw CocoaError(.coderReadCorrupt)
        }
        return run
    }
}

@MainActor
enum BenchmarkStore {
    static func save(_ run: BenchmarkRun, in context: ModelContext) throws {
        let record = try BenchmarkRunRecord(run: run)
        context.insert(record)
        do { try context.save() } catch { context.rollback(); throw error }
    }
    static func delete(_ records: [BenchmarkRunRecord], in context: ModelContext) throws {
        for record in records { context.delete(record) }
        do { try context.save() } catch { context.rollback(); throw error }
    }
}
