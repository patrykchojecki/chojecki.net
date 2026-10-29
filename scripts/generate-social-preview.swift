// Rebuild on macOS with Apple's SF Pro fonts installed in /Library/Fonts:
// swift scripts/generate-social-preview.swift
// Font outlines are baked into the artwork; no font files are published.
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let width = 1200
let height = 630
let output = URL(fileURLWithPath: "images/social-preview-signature-stroke")

func font(_ filename: String, size: CGFloat) -> CTFont {
    let url = URL(fileURLWithPath: "/Library/Fonts/\(filename)")
    guard let provider = CGDataProvider(url: url as CFURL),
          let face = CGFont(provider) else {
        fatalError("Install SF Pro before rebuilding: \(url.path)")
    }
    return CTFontCreateWithGraphicsFont(face, size, nil, nil)
}

func outline(_ text: String, font: CTFont, x: CGFloat, baseline: CGFloat,
             tracking: CGFloat = 0) -> CGPath {
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTKernAttributeName as String): tracking
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
    let path = CGMutablePath()
    for run in CTLineGetGlyphRuns(line) as! [CTRun] {
        let count = CTRunGetGlyphCount(run)
        var glyphs = [CGGlyph](repeating: 0, count: count)
        var positions = [CGPoint](repeating: .zero, count: count)
        CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
        CTRunGetPositions(run, CFRange(location: 0, length: 0), &positions)
        for index in 0..<count {
            if let glyph = CTFontCreatePathForGlyph(font, glyphs[index], nil) {
                let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1,
                    tx: x + positions[index].x, ty: baseline - positions[index].y)
                path.addPath(glyph, transform: transform)
            }
        }
    }
    return path
}

func svgPath(_ path: CGPath) -> String {
    func point(_ p: CGPoint) -> String { String(format: "%.3f %.3f", p.x, p.y) }
    var commands: [String] = []
    path.applyWithBlock { pointer in
        let element = pointer.pointee
        switch element.type {
        case .moveToPoint: commands.append("M" + point(element.points[0]))
        case .addLineToPoint: commands.append("L" + point(element.points[0]))
        case .addQuadCurveToPoint:
            commands.append("Q" + point(element.points[0]) + " " + point(element.points[1]))
        case .addCurveToPoint:
            commands.append("C" + point(element.points[0]) + " " + point(element.points[1]) + " " + point(element.points[2]))
        case .closeSubpath: commands.append("Z")
        @unknown default: fatalError("Unsupported path element")
        }
    }
    return commands.joined(separator: " ")
}

let displayFont = font("SF-Pro-Display-Bold.otf", size: 148)
let domainFont = font("SF-Pro-Text-Regular.otf", size: 24)
let lettering = [
    outline("Patryk", font: displayFont, x: 68, baseline: 262, tracking: -4),
    outline("Chojecki", font: displayFont, x: 68, baseline: 385, tracking: -4),
    outline("chojecki.net", font: domainFont, x: 76, baseline: 564)
]

let stroke = CGMutablePath()
stroke.move(to: CGPoint(x: 82, y: 431))
stroke.addCurve(to: CGPoint(x: 506, y: 431), control1: CGPoint(x: 235, y: 416), control2: CGPoint(x: 366, y: 407))
stroke.addCurve(to: CGPoint(x: 856, y: 410), control1: CGPoint(x: 644, y: 456), control2: CGPoint(x: 724, y: 449))
stroke.addCurve(to: CGPoint(x: 1090, y: 252), control1: CGPoint(x: 988, y: 370), control2: CGPoint(x: 1090, y: 313))
stroke.addCurve(to: CGPoint(x: 925, y: 225), control1: CGPoint(x: 1090, y: 184), control2: CGPoint(x: 993, y: 192))
stroke.addCurve(to: CGPoint(x: 773, y: 397), control1: CGPoint(x: 838, y: 268), control2: CGPoint(x: 758, y: 346))
stroke.addCurve(to: CGPoint(x: 1138, y: 423), control1: CGPoint(x: 788, y: 478), control2: CGPoint(x: 962, y: 481))
stroke.addCurve(to: CGPoint(x: 1240, y: 392), control1: CGPoint(x: 1175, y: 411), control2: CGPoint(x: 1215, y: 398))

let svg = """
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630" role="img" aria-labelledby="title desc">
<title id="title">Patryk Chojecki</title>
<desc id="desc">Patryk Chojecki in SF Pro Display Bold above an orange signature stroke, with chojecki.net in SF Pro Text Regular on white.</desc>
<rect width="1200" height="630" fill="#ffffff"/>
<g fill="#222222">
\(lettering.map { "<path d=\"\(svgPath($0))\"/>" }.joined(separator: "\n"))
</g>
<path d="\(svgPath(stroke))" fill="none" stroke="#de7536" stroke-width="6" stroke-linecap="round"/>
</svg>

"""
try svg.write(to: output.appendingPathExtension("svg"), atomically: true, encoding: .utf8)

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
    bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
context.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: width, height: height))
context.translateBy(x: 0, y: CGFloat(height))
context.scaleBy(x: 1, y: -1)
context.setFillColor(CGColor(srgbRed: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 1))
for path in lettering {
    context.addPath(path)
    context.fillPath()
}
context.setStrokeColor(CGColor(srgbRed: 222 / 255, green: 117 / 255, blue: 54 / 255, alpha: 1))
context.setLineWidth(6)
context.setLineCap(.round)
context.addPath(stroke)
context.strokePath()
let image = context.makeImage()!
let destination = CGImageDestinationCreateWithURL(output.appendingPathExtension("png") as CFURL,
    UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("PNG export failed") }
print("Created \(output.path).png (\(width)×\(height)) and outlined SVG")
print("Fonts: \(CTFontCopyPostScriptName(displayFont)), \(CTFontCopyPostScriptName(domainFont))")
