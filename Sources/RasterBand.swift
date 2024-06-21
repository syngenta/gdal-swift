//
//  RasterBand.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import gdal
import Foundation
import CoreGraphics

public enum RWFlag {
    case read
    case write

    public var falg: GDALRWFlag {
        switch self {
            case .read: return GF_Read
            case .write: return GF_Write
        }
    }
}

public class RasterBand {

    public let band: GDALRasterBandH

    public var dataType: DataType {
        let dataType = GDALGetRasterDataType(self.band)
        return DataType.from(dataType)
    }

    public init(band: GDALRasterBandH) {
        self.band = band
    }

    /// init
    /// - Parameters:
    ///     - dataset: Dataset from which will be getted band
    ///     - index: Band index
    public init(dataset: Dataset, index: Int32) {
        self.band = GDALGetRasterBand(dataset.dataset, index)
    }

    /// rasterIO
    /// - Parameters:
    ///     - flag: Either *read* to read a region of data, or write to *write* a region of data.
    ///     - rect: The region of the band to be accessed:
    ///         - x: The pixel offset to the top left corner. This would be zero to start from the left side.
    ///         - y: The line offset to the top left corner. This would be zero to start from the top
    ///         - width: The width of the region of the band to be accessed in pixels.
    ///         - height: The height of the region of the band to be accessed in lines.
    ///     - buffer: The buffer into which the data should be read, or from which it should be written.
    /// This buffer must contain at least bSize.width * bSize.height words of type eBufType.
    /// It is organized in left to right, top to bottom pixel order.
    /// Spacing is controlled by the *pixelSpace*, and *lineSpace* parameters.
    ///     - bSize: The size of the buffer image into which the desired region
    /// is to be read, or from which it is to be written
    ///     - pixelSpace: The byte offset from the start of one pixel value in *buffer* to the start of the
    /// next pixel value within a scanline. If defaulted (0) the size of the datatype eBufType is used.
    ///     - lineSpace: The byte offset from the start of one scanline in *buffer* to the start of the next.
    /// If defaulted (0) the size of the datatype eBufType * bSize.width is used.
    public func rasterIO(flag: RWFlag, rect: CGRect, buffer: UnsafeMutableRawPointer, bSize: CGSize,
                         pixelSpace: Int32 = 0, lineSpace: Int32 = 0) {
        GDALRasterIO(self.band,
                     flag.falg,
                     Int32(rect.origin.x),
                     Int32(rect.origin.y),
                     Int32(rect.width),
                     Int32(rect.height),
                     buffer,
                     Int32(bSize.width),
                     Int32(bSize.height),
                     self.dataType.type,
                     pixelSpace,
                     lineSpace)
    }

    /// rasterIO
    /// - Parameters:
    ///     - rect: The region of the band to be accessed:
    ///         - x: The pixel offset to the top left corner. This would be zero to start from the left side.
    ///         - y: The line offset to the top left corner. This would be zero to start from the top
    ///         - width: The width of the region of the band to be accessed in pixels.
    ///         - height: The height of the region of the band to be accessed in lines.
    ///     - bSize: The size of the buffer image into which the desired region is to be read
    ///     - type: Generic type of result
    public func rasterIO<T: LosslessStringConvertible>(rect: CGRect, bSize: CGSize, type: T.Type = T.self) -> [T] {

        let count = Int(bSize.width * bSize.height)

        let buffer = [T](repeating: T("0")!, count: count)

        self.rasterIO(flag: .read,
                      rect: rect,
                      buffer: UnsafeMutableRawPointer(mutating: buffer),
                      bSize: bSize)

        return buffer
    }
}
