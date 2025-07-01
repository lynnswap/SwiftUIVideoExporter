import Testing
@testable import SwiftUIVideoExporter
import SwiftUI

@Test func progressCallback() async throws {
    var values: [Double] = []
    _ = try await SwiftUIVideoExporter.export(
        duration: 2,
        fps: 10,
        renderSize: .init(width: 16, height: 16),
        displayScale: 1,
        progress: {
            print($0)
            values.append($0)
        }
    ) { _ in
        Color.red
    }
    #expect(values.count == 10)
    #expect(values.first == 0)
    #expect(values.last == 1)
}
