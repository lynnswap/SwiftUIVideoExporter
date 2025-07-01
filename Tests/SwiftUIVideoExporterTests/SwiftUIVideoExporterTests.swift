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
        progress: { values.append($0) }
    ) { _ in
        Color.red
    }
    // progress should be reported at start, roughly every 10%, and at the end
    // for a total of eleven callbacks
    #expect(values.count == 11)
    #expect(values.first == 0)
    #expect(values.last == 1)
}
