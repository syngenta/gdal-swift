//
//  Bounds.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/6/19.
//

import Foundation

// swiftlint:disable identifier_name
struct Bounds {
    struct Point {
        let x: Double
        let y: Double
    }

    let min: Point
    let max: Point
    let tileSize: Double
    var transform: [Double]

    init(x: Int, y: Int, z: Int, tileSize: Int = 256) {
        self.min = Bounds.pixelsToMeters(x: x, y: y, zoom: z, tileSize: tileSize)
        self.max = Bounds.pixelsToMeters(x: x + 1, y: y + 1, zoom: z, tileSize: tileSize)
        self.tileSize = Double(tileSize)

        self.transform = [
            self.min.x, // координата x верхнего левого угла
            (self.max.x - self.min.x) / self.tileSize, // ширина пикселя
            0, // поворот, 0, если изображение ориентировано на север
            -self.min.y, // координата y верхнего левого угла
            0, // поворот, 0, если изображение ориентировано на север
            -((self.max.x - self.min.x) / self.tileSize) // высота пикселя
        ]
    }
}

extension Bounds {
    private static var originShift: Double {
        return 2 * .pi * 6378137 / 2.0
    }

    private static func resolution(zoom: Int, tileSize: Int) -> Double {
        let resolution = 2 * .pi * 6378137 / Double(tileSize)
        let _zoom = pow(2.0, Double(zoom))

        return resolution / _zoom
    }

    private static func pixelsToMeters(x: Int, y: Int, zoom: Int, tileSize: Int) -> Point {
        let px = Double(x * tileSize)
        let py = Double(y * tileSize)

        let resolution = self.resolution(zoom: zoom, tileSize: tileSize)
        let x = px * resolution - self.originShift
        let y = py * resolution - self.originShift
        return Point(x: x, y: y)
    }
}
// swiftlint:enable identifier_name
