//
//  Warp.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import gdal
import Foundation

public class Warp {
    public enum E: Error {
        case reprojectImage(comment: String)
    }

    public enum ResampleAlgorithm {
        /// Nearest neighbour (select on one input pixel)
        case nearestNeighbour

        /// Bilinear (2x2 kernel)
        case bilinear

        /// Cubic Convolution Approximation (4x4 kernel)
        case cubic

        /// Cubic B-Spline Approximation (4x4 kernel)
        case cubicSpline

        /// Lanczos windowed sinc interpolation (6x6 kernel)
        case lanczos

        /// Average (computes the average of all non-NODATA contributing pixels)
        case average

        /// Mode (selects the value which appears most often of all the sampled points)
        case mode

        public var alg: GDALResampleAlg {
            switch self {
                case .nearestNeighbour: return GRA_NearestNeighbour
                case .bilinear: return GRA_Bilinear
                case .cubic: return GRA_Cubic
                case .cubicSpline: return GRA_CubicSpline
                case .lanczos: return GRA_Lanczos
                case .average: return GRA_Average
                case .mode: return GRA_Mode
            }
        }
    }

    // swiftlint:disable line_length
    public static func reprojectImage(src: Dataset, srcWKT: UnsafePointer<Int8>? = nil, dst: Dataset, dstWKT: UnsafePointer<Int8>? = nil, resampleAlgorithm: ResampleAlgorithm, warpMemoryLimit: Double = 0, maxError: Double = 0, progress: GDALProgressFunc? = nil, progressArg: UnsafeMutableRawPointer? = nil, options: UnsafeMutablePointer<GDALWarpOptions>? = nil) throws {
        let result = GDALReprojectImage(src.dataset,
                                        srcWKT,
                                        dst.dataset,
                                        dstWKT,
                                        resampleAlgorithm.alg,
                                        warpMemoryLimit,
                                        maxError,
                                        progress,
                                        progressArg,
                                        options)

        guard result.rawValue == 0 else {
            throw E.reprojectImage(comment: "Can't reproject image (error code - \(result)")
        }
    }
    // swiftlint:enable line_length
}
