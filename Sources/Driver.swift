//
//  Driver.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import gdal
import Foundation

public class Driver {

    public enum Identifier: String {
        case MEM
        case GTiff
    }

    public static func registerAll() {
        GDALAllRegister()
    }

    public static func deregisterAll() {
        GDALDestroyDriverManager()
    }

    public let driver: GDALDriverH

    public init(driver: GDALDriverH) {
        self.driver = driver
    }

    public init(identifier: Identifier) {
        let _identifier = identifier.rawValue.unsafeMutablePointer
        self.driver = GDALGetDriverByName(UnsafePointer<Int8>(_identifier))
        _identifier.deallocate()
    }

    public func register() {
        GDALRegisterDriver(self.driver)
    }

    public func deregister() {
        GDALDeregisterDriver(self.driver)
    }
}
