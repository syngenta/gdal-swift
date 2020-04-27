//
//  TileProvider.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import Foundation
import CoreGraphics
import ImageIO

// swiftlint:disable identifier_name
public struct TileCoordinates {
    public let x: Int
    public let y: Int
    public let z: Int

    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}
// swiftlint:enable identifier_name

public class TileProvider {
    public enum E: Error {
        case incorrectRasterCount
        case incorrectImage
        case unsupportedDataType
    }

    public init() {
        Driver.registerAll()
    }

    deinit {
        Driver.deregisterAll()
    }

    public func visible(path: String, coordinates: TileCoordinates, tileSize: Int = 256) throws -> Data {

        let (_, dst) = try self.warp(path: path, coordinates: coordinates, tileSize: tileSize, bandCount: 3, resampleAlgorithm: .cubicSpline)

        let rect = CGRect(x: 0, y: 0, width: tileSize, height: tileSize)
        let size = CGSize(width: tileSize, height: tileSize)

        let red = dst.rasterBand(index: 1).rasterIO(rect: rect, bSize: size, type: UInt8.self)
        let green = dst.rasterBand(index: 2).rasterIO(rect: rect, bSize: size, type: UInt8.self)
        let blue = dst.rasterBand(index: 3).rasterIO(rect: rect, bSize: size, type: UInt8.self)

        let bitmap = zip(red, zip(green, blue)).flatMap {
            Color(red: $0.0, green: $0.1.0, blue: $0.1.1).bitmap
        }

        guard let image = self.image(bitmap: bitmap, type: .premultipliedLast, size: size) else {
            throw E.incorrectImage
        }

        return image
    }

    public func ndvi(path: String, coordinates: TileCoordinates, tileSize: Int = 256) throws -> Data {
        return try self.ndvi(path: path, coordinates: coordinates, tileSize: tileSize) {
            Color.ndvi($0)
        }
    }

    public func contrast(path: String, coordinates: TileCoordinates, tileSize: Int = 256) throws -> Data {
        let extremums = try self.contrastExtremums(path: path)

        return try self.ndvi(path: path, coordinates: coordinates, tileSize: tileSize) {
            Color.contrast($0, min: extremums.min, max: extremums.max)
        }
    }

    public func contrastExtremums(path: String) throws -> (min: Float, max: Float) {
        let dataset = try Dataset(path: URL(fileURLWithPath: path))
        return try self.contrastExtremums(dataset: dataset)
    }
}

private extension TileProvider {

    func warp(path: String, coordinates: TileCoordinates, tileSize: Int, bandCount: Int32, resampleAlgorithm: Warp.ResampleAlgorithm) throws -> (src: Dataset, dst: Dataset) {

        let src = try Dataset(path: URL(fileURLWithPath: path))

        guard bandCount > 0 else { throw E.incorrectRasterCount }
        guard src.rasterCount == bandCount else { throw E.incorrectRasterCount }

        let dataType = src.dataType(band: 1)

        let bounds = Bounds(x: coordinates.x, y: coordinates.y, z: coordinates.z)
        let driver = Driver(identifier: .MEM)

        let dst = try Dataset(driver: driver,
                              size: CGSize(width: tileSize, height: tileSize),
                              bandCount: bandCount,
                              dataType: dataType)
        dst.set(projection: src.projection)
        dst.set(geoTransform: bounds.geoTransform)

        try Warp.reprojectImage(src: src, dst: dst, resampleAlgorithm: resampleAlgorithm)

        return (src, dst)
    }

    func ndvi(path: String, coordinates: TileCoordinates, tileSize: Int = 256, colorDecoder: (_ value: Float) -> Color) throws -> Data {
        let (_, dst) = try self.warp(path: path, coordinates: coordinates, tileSize: tileSize, bandCount: 1, resampleAlgorithm: .cubicSpline)

        let rect = CGRect(x: 0, y: 0, width: tileSize, height: tileSize)
        let size = CGSize(width: tileSize, height: tileSize)

        let band = dst.rasterBand(index: 1)

        var ndvis = [Float]()

        switch dst.dataType(band: 1) {
            case .UInt16:
                ndvis = band.rasterIO(rect: rect, bSize: size, type: UInt16.self).map {
                    (Float($0) - Float(UInt16.max) / 2) / 10000.0
                }
            case .Float32:
                ndvis = band.rasterIO(rect: rect, bSize: size, type: Float.self)
            default: throw E.unsupportedDataType
        }

        let bitmap = ndvis.reduce(into: [UInt8]()) {
            $0 += colorDecoder($1).bitmap
        }
        guard let image = self.image(bitmap: bitmap, type: .premultipliedLast, size: size) else {
            throw E.incorrectImage
        }

        return image
    }

    func contrastExtremums(dataset: Dataset) throws -> (min: Float, max: Float) {
        let size = dataset.rasterSize
        let rect = CGRect(origin: CGPoint.zero, size: size)

        let band = dataset.rasterBand(index: 1)

        var values = [Float]()

        switch dataset.dataType(band: 1) {
            case .Float32:
                values = band.rasterIO(rect: rect, bSize: size)
            case .UInt16:
                values = band.rasterIO(rect: rect, bSize: size, type: UInt16.self).map {
                    (Float($0) - Float(UInt16.max) / 2) / 10000.0
                }
            default: throw E.unsupportedDataType
        }

        let _values = values.filter { $0 > 0 }.sorted()

        let step = _values.count / 100
        let min = _values[step]
        let max = _values[(_values.count - 1) - step]

        return (min, max)
    }

    func image(bitmap: [UInt8], type: CGImageAlphaInfo, size: CGSize) -> Data? {

        let data = UnsafeMutableRawPointer(mutating: bitmap)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: type.rawValue)

        let context = CGContext(data: data,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: Int(4 * size.width),
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)

        guard let image = context?.makeImage() else {
            return nil
        }
        guard let mutableData = CFDataCreateMutable(nil, 0) else {
            return nil
        }
        guard let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return mutableData as Data
    }
}
