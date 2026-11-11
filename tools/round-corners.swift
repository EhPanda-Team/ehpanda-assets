// Rounds the corners of the marketplace screenshots, as the App Store does, because AltStore and
// SideStore show screenshots as they are and do not round them.
//
//     swift tools/round-corners.swift
//
// Reads the unrounded originals from `source/<device>/` and writes the rounded images to
// `app-marketplace/<device>/` under the same names and at the same size. Always start from `source/`,
// never from `app-marketplace/`: rounding an already rounded image would round it twice.
//
// The radius is the App Store's, as a share of the image: on apps.apple.com the screenshots of the
// 6.9-inch iPhone class (`.iphone-d74.portrait`) have `border-radius: 12.8% / 5.7%`, that is 12.8% of the
// width across and 5.7% of the height down. At 1260 x 2736 pixels that is 161.28 x 155.95 pixels.
//
// The corner is the continuous (squircle) corner iOS draws, not a quarter circle: the edge starts to
// bend 1.52866 x the radius before the corner, as in Apple's continuous rounded rectangle. It is built
// from two cubic curves and one circular arc per corner, so that it is smooth where the parts meet
// (the construction of the well-known "squircle" corner, with its smoothing set to 0.52866).
// The picture outside the shape becomes transparent, with an antialiased edge.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let radiusAcross = 0.128  // share of the width
let radiusDown = 0.057    // share of the height
let extent = 1.52866483   // how far along the edge the curve starts, in radii
let smoothing = extent - 1  // the same value as a smoothing factor: extent = (1 + smoothing) x radius
let devices = ["iphone"]

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()

/// One corner in units of its radius. It starts on the incoming edge, `extent` radii before the corner,
/// and ends on the outgoing edge, `extent` radii after it. A point is `(x, y)`: x runs along the incoming
/// edge and y along the outgoing edge, both measured from where the corner starts. It is a curve that
/// leaves the edge, a circular arc and a curve that joins the next edge, all cubic Bezier curves.
struct Corner {
    typealias Segment = (CGPoint, CGPoint, CGPoint)  // two control points and the end point
    let first: Segment
    let arc: Segment
    let last: Segment

    init(smoothing xi: Double) {
        let reach = 1 + xi
        let arcMeasure = 90 * (1 - xi) * Double.pi / 180
        let chordLeg = sin(arcMeasure / 2) * 2.0.squareRoot()  // the arc's chord spans (chordLeg, chordLeg)
        let alpha = (Double.pi / 2 - arcMeasure) / 2
        let beta = Double.pi / 4 * xi  // where the curve meets the arc, its direction away from the edge
        let c = tan(alpha / 2) * cos(beta)
        let d = c * tan(beta)
        let b = (reach - chordLeg - c - d) / 3
        let a = 2 * b

        let arcStart = CGPoint(x: a + b + c, y: d)
        let arcEnd = CGPoint(x: arcStart.x + chordLeg, y: arcStart.y + chordLeg)
        // The arc as one cubic curve: it leaves at angle beta and arrives at angle beta + arcMeasure.
        let k = 4.0 / 3.0 * tan(arcMeasure / 4)
        first = (CGPoint(x: a, y: 0), CGPoint(x: a + b, y: 0), arcStart)
        arc = (CGPoint(x: arcStart.x + k * cos(beta), y: arcStart.y + k * sin(beta)),
               CGPoint(x: arcEnd.x - k * cos(beta + arcMeasure), y: arcEnd.y - k * sin(beta + arcMeasure)),
               arcEnd)
        last = (CGPoint(x: arcEnd.x + d, y: arcEnd.y + c), CGPoint(x: arcEnd.x + d, y: arcEnd.y + b + c),
                CGPoint(x: arcEnd.x + d, y: arcEnd.y + a + b + c))
    }
}

/// The outline of a `width` x `height` image (y runs downwards) with continuous corners of `rx` x `ry` pixels.
func outline(width: Double, height: Double, rx: Double, ry: Double) -> CGPath {
    let corner = Corner(smoothing: smoothing)
    let path = CGMutablePath()
    // Clockwise from the top right. `u` is the direction of the incoming edge and `v` that of the outgoing one.
    let frames: [(origin: CGPoint, u: CGPoint, v: CGPoint)] = [
        (CGPoint(x: width - extent * rx, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)),        // top right
        (CGPoint(x: width, y: height - extent * ry), CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 0)),  // bottom right
        (CGPoint(x: extent * rx, y: height), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: -1)),         // bottom left
        (CGPoint(x: 0, y: extent * ry), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: 0)),               // top left
    ]
    for (index, frame) in frames.enumerated() {
        // The radius of an axis is the one of the image side it runs along.
        let sx = frame.u.x != 0 ? rx : ry
        let sy = frame.v.x != 0 ? rx : ry
        func map(_ q: CGPoint) -> CGPoint {
            CGPoint(x: frame.origin.x + frame.u.x * q.x * sx + frame.v.x * q.y * sy,
                    y: frame.origin.y + frame.u.y * q.x * sx + frame.v.y * q.y * sy)
        }
        if index == 0 { path.move(to: map(.zero)) } else { path.addLine(to: map(.zero)) }
        for segment in [corner.first, corner.arc, corner.last] {
            path.addCurve(to: map(segment.2), control1: map(segment.0), control2: map(segment.1))
        }
    }
    path.closeSubpath()
    return path
}

func load(_ url: URL) -> CGImage? {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
}

func round(_ image: CGImage) -> CGImage? {
    let width = image.width, height = image.height
    let space = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    context.setShouldAntialias(true)
    context.setAllowsAntialiasing(true)
    // CoreGraphics counts y upwards; the outline is drawn from the top, so flip it.
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    context.addPath(outline(width: Double(width), height: Double(height),
                            rx: radiusAcross * Double(width), ry: radiusDown * Double(height)))
    context.clip()
    // The image is drawn upright in the flipped context.
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    return context.makeImage()
}

func save(_ image: CGImage, to url: URL) -> Bool {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return false }
    CGImageDestinationAddImage(destination, image, nil)
    return CGImageDestinationFinalize(destination)
}

var failed = false
for device in devices {
    let input = root.appendingPathComponent("source/\(device)")
    let output = root.appendingPathComponent("app-marketplace/\(device)")
    let names = ((try? FileManager.default.contentsOfDirectory(atPath: input.path)) ?? []).filter { $0.hasSuffix(".png") }.sorted()
    if names.isEmpty { print("no screenshots in source/\(device)"); failed = true }
    for name in names {
        guard let image = load(input.appendingPathComponent(name)), let rounded = round(image),
              save(rounded, to: output.appendingPathComponent(name)) else {
            print("could not round source/\(device)/\(name)"); failed = true; continue
        }
        print("app-marketplace/\(device)/\(name)  \(rounded.width) x \(rounded.height)")
    }
}
exit(failed ? 1 : 0)
