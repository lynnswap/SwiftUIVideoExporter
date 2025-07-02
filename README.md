# SwiftUIVideoExporter

SwiftUIVideoExporter is a Swift package that captures frames from a SwiftUI view and exports them as a video file. This utility uses **AVFoundation** to write frames and supports iOS and macOS.

## Features
- Render SwiftUI views at custom sizes and frame rates
- Encode videos as `.mp4`, `.mov`, or `.m4v`
- Track progress of the export process in ~10% increments

## Usage
```swift
import SwiftUIVideoExporter

let url = try await SwiftUIVideoExporter.export(
    duration: 5,
    fps: 30,
    renderSize: CGSize(width: 1920, height: 1080),
    displayScale: UIScreen.main.scale,
    // called about every 10% of the export
    progress: { value in
        print("progress", value)
    }
) { time in
    // Build your frame here
    MyAnimatedView(time: time)
}
```

## Apps Using

<p float="left">
    <a href="https://apps.apple.com/jp/app/tweetpd/id1671411031"><img src="https://i.imgur.com/AC6eGdx.png" height="65"></a>
</p>

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
