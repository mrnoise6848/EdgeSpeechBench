import Foundation

nonisolated enum WordErrorRate {
    static func tokens(_ text: String) -> [String] {
        text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }
    static func calculate(reference: String?, hypothesis: String) -> Double? {
        guard let reference else { return nil }
        let expected = tokens(reference)
        let actual = tokens(hypothesis)
        guard !expected.isEmpty else { return nil }
        var previous = Array(0...actual.count)
        for (i, word) in expected.enumerated() {
            var current = [i + 1]
            current.reserveCapacity(actual.count + 1)
            for (j, candidate) in actual.enumerated() {
                current.append(min(previous[j + 1] + 1, current[j] + 1,
                                   previous[j] + (word == candidate ? 0 : 1)))
            }
            previous = current
        }
        return Double(previous[actual.count]) / Double(expected.count)
    }
}
