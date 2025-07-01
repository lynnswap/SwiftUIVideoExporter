# SwiftUIVideoExporter

SwiftUIVideoExporter is a Swift package that captures frames from a SwiftUI view and exports them as a video file. This utility uses **AVFoundation** to write frames and supports iOS and macOS.

## Features
- Render SwiftUI views at custom sizes and frame rates
- Encode videos as `.mp4`, `.mov`, or `.m4v`

## Usage
```swift
import SwiftUIVideoExporter

let url = try await SwiftUIVideoExporter.export(
    duration: 5,
    fps: 30,
    renderSize: CGSize(width: 1920, height: 1080),
    displayScale: UIScreen.main.scale
) { time in
    // Build your frame here
    MyAnimatedView(time: time)
}
```

## License
See [LICENSE](LICENSE) for details.
