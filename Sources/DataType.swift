//
//  DataType.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import gdal

public enum DataType {
    ///Unknown or unspecified type
    case unknown

    /// Eight bit unsigned integer
    case Byte

    /// Sixteen bit unsigned integer
    case UInt16

    /// Sixteen bit signed integer
    case Int16

    /// Thirty two bit unsigned integer
    case UInt32

    /// Thirty two bit signed integer
    case Int32

    /// Thirty two bit floating point
    case Float32

    /// Sixty four bit floating point
    case Float64

    /// Complex Int16
    case CInt16

    /// Complex Int32
    case CInt32

    /// Complex Float32
    case CFloat32

    /// Complex Float64
    case CFloat64

    /// maximum type # + 1
    case typeCount

    public var type: GDALDataType {
        switch self {
            case .unknown: return GDT_Unknown
            case .Byte: return GDT_Byte
            case .UInt16: return GDT_UInt16
            case .Int16: return GDT_Int16
            case .UInt32: return GDT_UInt32
            case .Int32: return GDT_Int32
            case .Float32: return GDT_Float32
            case .Float64: return GDT_Float64
            case .CInt16: return GDT_CInt16
            case .CInt32: return GDT_CInt32
            case .CFloat32: return GDT_CFloat32
            case .CFloat64: return GDT_CFloat64
            case .typeCount: return GDT_TypeCount
        }
    }

    public static func from(_ dataType: GDALDataType) -> DataType {
        switch dataType {
            case GDT_Unknown: return .unknown
            case GDT_Byte: return .Byte
            case GDT_UInt16: return .UInt16
            case GDT_Int16: return .Int16
            case GDT_UInt32: return .UInt32
            case GDT_Int32: return .Int32
            case GDT_Float32: return .Float32
            case GDT_Float64: return .Float64
            case GDT_CInt16: return .CInt16
            case GDT_CInt32: return .CInt32
            case GDT_CFloat32: return .CFloat32
            case GDT_CFloat64: return .CFloat64
            case GDT_TypeCount: return .typeCount
            default: return .unknown
        }
    }
}
