import Foundation
import Darwin

nonisolated enum DeviceInformation {
    static func capture(bundle: Bundle = .main) -> DeviceContext {
        var system = utsname()
        uname(&system)
        let hardware = withUnsafePointer(to: &system.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: system.machine)) {
                String(cString: $0)
            }
        }
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        #if targetEnvironment(simulator)
        let simulated = true
        let model = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? hardware
        #else
        let simulated = false
        let model = hardware
        #endif
        return DeviceContext(hardware: model, os: ProcessInfo.processInfo.operatingSystemVersionString,
                             appVersion: "\(version) (\(build))", isSimulator: simulated)
    }
}
