//
//  Dataset.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import gdal
import Foundation
import CoreGraphics

public class Dataset {
    public enum E: Error {
        case wrongPath(path: URL, comment: String)
        case open(path: URL, comment: String)
        case create(comment: String)
    }

    public enum Access: UInt32 {
        case readOnly
        case update
    }

    public let dataset: GDALDatasetH

    public var rasterCount: Int32 {
        return GDALGetRasterCount(self.dataset)
    }

    public var rasterXSize: Int32 {
        return GDALGetRasterXSize(self.dataset)
    }

    public var rasterYSize: Int32 {
        return GDALGetRasterYSize(self.dataset)
    }

    public var rasterSize: CGSize {
        return CGSize(width: Int(self.rasterXSize), height: Int(self.rasterYSize))
    }

    public var projection: UnsafePointer<Int8> {
        return GDALGetProjectionRef(self.dataset)
    }

    public func set(projection: UnsafePointer<Int8>) {
        GDALSetProjection(self.dataset, projection)
    }

    public func set(geoTransform: UnsafeMutablePointer<Double>) {
        GDALSetGeoTransform(self.dataset, geoTransform)
    }

    public func rasterBand(index: Int32) -> RasterBand {
        return .init(dataset: self, index: index)
    }

    public func dataType(band index: Int32) -> DataType {
        return self.rasterBand(index: index).dataType
    }

    public init(path: URL, access: Access = .readOnly) throws {
        guard path.isFileURL else {
            throw E.wrongPath(path: path, comment: "Must be file url")
        }
        let _path = path.path.unsafeMutablePointer
        defer {
            _path.deallocate()
        }

        let _access = GDALAccess(rawValue: access.rawValue)

        guard let dataset = GDALOpen(UnsafePointer<Int8>(_path), _access) else {
            throw E.open(path: path, comment: "Can't open dataset")
        }

        self.dataset = dataset
    }

    public init(driver: Driver, name: String = "dataset", size: CGSize, bandCount: Int32,
                dataType: DataType, papszOptions: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil) throws {
        let _name = name.unsafeMutablePointer
        defer {
            _name.deallocate()
        }

        let dataset = GDALCreate(driver.driver,
                                 UnsafePointer<Int8>(_name),
                                 Int32(size.width),
                                 Int32(size.height),
                                 bandCount,
                                 dataType.type,
                                 papszOptions)

        guard let _dataset = dataset else {
            let comment = """
            Can't create dataset (driver - \(driver), size - \(size),
            bandCount - \(bandCount), dataType - \(dataType), papszOptions - \(String(describing: papszOptions))
            """
            throw E.create(comment: comment)
        }

        self.dataset = _dataset
    }

    deinit {
        GDALClose(self.dataset)
    }
}
