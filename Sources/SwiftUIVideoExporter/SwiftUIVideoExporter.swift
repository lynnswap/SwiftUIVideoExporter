// The Swift Programming Language
// https://docs.swift.org/swift-book
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

public enum SwiftUIVideoExporter {
    static func export<V: View>(
        duration: Double = 10,
        fps: Int = 30,
        renderSize: CGSize,
        fileType: AVFileType = .mp4,
        displayScale: CGFloat,
        buildFrame: @escaping @MainActor (Double) -> V
    ) async throws -> URL {
        
        let totalFrames = Int(duration * Double(fps))
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(fileType.fileExtension)
        
        let writer = try AVAssetWriter(outputURL: tempURL, fileType: fileType)
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey:  renderSize.width,
            AVVideoHeightKey: renderSize.height
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        writer.add(input)
        
        guard writer.startWriting() else { throw writer.error! }
        writer.startSession(atSourceTime: .zero)
        let scale = displayScale
        for frame in 0..<totalFrames {
            let t = Double(frame) / Double(fps)
            let cgImage:CGImage? = await MainActor.run{
                let renderer = ImageRenderer(content:  buildFrame(t))
                renderer.scale = scale
                renderer.proposedSize = .init(renderSize)
#if canImport(UIKit)
                return renderer.uiImage?.cgImage
#else
                return renderer.nsImage?.cgImage
#endif
            }
            guard let cgImage else { continue }
            guard let pixelBuffer = cgImage.toPixelBuffer() else { continue }
            
            let presentationTime = CMTime(value: CMTimeValue(frame), timescale: CMTimeScale(fps))
            while !input.isReadyForMoreMediaData { await Task.yield() }
            adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }
        input.markAsFinished()
        await writer.finishWriting()
        return tempURL
    }
}

private extension CGImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        var buffer: CVPixelBuffer?
        let width  = self.width
        let height = self.height
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs,
            &buffer
        )
        guard status == kCVReturnSuccess, let px = buffer else { return nil }
        
        CVPixelBufferLockBaseAddress(px, [])
        if let ctx = CGContext(
            data: CVPixelBufferGetBaseAddress(px),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(px),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) {
            ctx.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        CVPixelBufferUnlockBaseAddress(px, [])
        return px
    }
}
#if canImport(AppKit)
extension NSImage {
    var cgImage: CGImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
}
#endif

private extension AVFileType {
    var fileExtension: String {
        if let ext = UTType(self.rawValue)?.preferredFilenameExtension {
            return ext
        }
        switch self {
        case .mov: return "mov"
        case .mp4: return "mp4"
        case .m4v: return "m4v"
        default: return "mp4"
        }
    }
}
