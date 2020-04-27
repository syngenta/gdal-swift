//
//  Helpers.swift
//  gdal-swift
//
//  Created by Evegeny Kalashnikov on 6/19/19.
//

import Foundation

extension String {
    public var unsafeMutablePointer: UnsafeMutablePointer<Int8> {
        return strdup(self)
    }
}
