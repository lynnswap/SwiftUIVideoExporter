import Testing
@testable import SwiftUIVideoExporter
import SwiftUI

@Test func progressCallback() async throws {
    var values: [Double] = []
    _ = try await SwiftUIVideoExporter.export(
        duration: 0.1,
        fps: 2,
        renderSize: .init(width: 16, height: 16),
        displayScale: 1,
        progress: { values.append($0) }
    ) { _ in
        Color.red
    }
    #expect(!values.isEmpty)
    #expect(values.first == 0)
    #expect(values.last == 1)
}
