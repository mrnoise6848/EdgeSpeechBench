import Foundation
import Darwin

actor MemorySampler {
    private var peak: UInt64?
    private var sampling: Task<Void, Never>?
    nonisolated static func footprint() -> UInt64? {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let status = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        return status == KERN_SUCCESS ? info.phys_footprint : nil
    }
    func start() {
        peak = Self.footprint()
        sampling = Task {
            while !Task.isCancelled {
                self.sample()
                do { try await Task.sleep(for: .milliseconds(100)) } catch { break }
            }
        }
    }
    private func sample() {
        if let value = Self.footprint() { peak = max(peak ?? 0, value) }
    }
    func stop() async -> UInt64? {
        sampling?.cancel()
        await sampling?.value
        sampling = nil
        sample()
        return peak
    }
}
