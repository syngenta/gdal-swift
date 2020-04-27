//
//  Color.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import Foundation

struct Color {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8

    var bitmap: [UInt8] {
        var alpha = self.alpha

        if self.red == 0x0 && self.green == 0x0 && self.blue == 0x0 {
            alpha = 0x0
        }

        return [self.red, self.green, self.blue, alpha]
    }

    static var clear: Color {
        return .init(hex: 0x0, alpha: 0)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(hex: UInt32, alpha: UInt8 = 255) {
        let red = UInt8((hex & 0xFF0000) >> 16)
        let green = UInt8((hex & 0x00FF00) >> 8 )
        let blue = UInt8((hex & 0x0000FF))
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    // swiftlint:disable identifier_name control_statement trailing_semicolon
    init(hue h: UInt16, saturation s: Float, value v: Float, alpha: UInt8 = 255) {
        var r: Float = 0
        var g: Float = 0
        var b: Float = 0

        if s == 0 {
            r = v; g = v; b = v;
        } else {
            let sector = Float(h) / 60
            let i = sector.rounded(.down)
            let f = sector - i

            let p = v * (1 - s)
            let q = v * (1 - (s * f))
            let t = v * (1 - (s * (1 - f)))

            switch(i) {
            case 0:
                r = v; g = t; b = p
            case 1:
                r = q; g = v; b = p
            case 2:
                r = p; g = v; b = t
            case 3:
                r = p; g = q; b = v
            case 4:
                r = t; g = p; b = v
            default:
                r = v; g = p; b = q
            }
        }
        self.init(red: UInt8(255 * r), green: UInt8(255 * g), blue: UInt8(255 * b), alpha: alpha)
    }
    // swiftlint:enable identifier_name control_statement trailing_semicolon

    static func interpolate(range: ClosedRange<Float>, ndvi: Float, color: (one: UInt32, two: UInt32)) -> Color {

        func interpolate(range: ClosedRange<Float>, ndvi: Float, color1: UInt8, color2: UInt8) -> UInt8 {
            let range1 = range.lowerBound
            let range2 = range.upperBound

            let color = (( ndvi - range1) * (Float(color2) - Float(color1)) / (range2 - range1)) + Float(color1)
            return UInt8(color)
        }

        let color1 = Color(hex: color.one)
        let color2 = Color(hex: color.two)

        let red = interpolate(range: range, ndvi: ndvi, color1: color1.red, color2: color2.red)
        let green = interpolate(range: range, ndvi: ndvi, color1: color1.green, color2: color2.green)
        let blue = interpolate(range: range, ndvi: ndvi, color1: color1.blue, color2: color2.blue)

        return Color(red: red, green: green, blue: blue)
    }

    static func ndvi(_ value: Float) -> Color {
        switch value {
        case ...0: return Color.clear
        case 0...0.05: return Color(hex: 0x422112)
        case 0.05...0.20:
            return self.interpolate(range: 0.05...0.20, ndvi: value, color: (0x422112, 0x9f512a))
        case 0.20...0.30:
            return self.interpolate(range: 0.20...0.30, ndvi: value, color: (0x9f512a, 0xcda915))
        case 0.30...0.35:
            return self.interpolate(range: 0.30...0.35, ndvi: value, color: (0xcda915, 0xfdfe03))
        case 0.35...0.40:
            return self.interpolate(range: 0.35...0.40, ndvi: value, color: (0xfdfe03, 0xe6ec06))
        case 0.40...0.45:
            return self.interpolate(range: 0.40...0.45, ndvi: value, color: (0xe6ec06, 0xd0df00))
        case 0.45...0.50:
            return self.interpolate(range: 0.45...0.50, ndvi: value, color: (0xd0df00, 0xb9cf02))
        case 0.50...0.55:
            return self.interpolate(range: 0.50...0.55, ndvi: value, color: (0xb9cf02, 0xa2c000))
        case 0.55...0.60:
            return self.interpolate(range: 0.55...0.60, ndvi: value, color: (0xa2c000, 0x8aaf00))
        case 0.60...0.65:
            return self.interpolate(range: 0.60...0.65, ndvi: value, color: (0x8aaf00, 0x72a000))
        case 0.65...0.70:
            return self.interpolate(range: 0.65...0.70, ndvi: value, color: (0x72a000, 0x5b8e03))
        case 0.70...0.75:
            return self.interpolate(range: 0.70...0.75, ndvi: value, color: (0x5b8e03, 0x458100))
        case 0.75...0.80:
            return self.interpolate(range: 0.75...0.80, ndvi: value, color: (0x458100, 0x2d7000))
        case 0.80...0.85:
            return self.interpolate(range: 0.80...0.85, ndvi: value, color: (0x2d7000, 0x25602d))
        case 0.85...0.90:
            return self.interpolate(range: 0.85...0.90, ndvi: value, color: (0x25602d, 0x15542d))
        case 0.90...1:
            return self.interpolate(range: 0.90...1, ndvi: value, color: (0x15542d, 0x003200))
        case 1...: return Color(hex: 0x003200)
        default: return Color.clear
        }
    }

    static func contrast(_ value: Float, min: Float, max: Float) -> Color {
        guard value > 0 else { return Color.clear }
        guard value > min else { return Color(hex: 0xff0000) }
        guard value < max else { return Color(hex: 0x0000ff) }

        // 240 - this is max value by HSV scale (blue color)
        let hue = UInt16((value - min) * 240 / (max - min))
        return Color(hue: hue, saturation: 0.8, value: 1)
    }
}
