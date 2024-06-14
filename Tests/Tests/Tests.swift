//
//  UnitTests.swift
//  UnitTests
//
//  Created by Evegeny Kalashnikov on 27.04.2020.
//

import XCTest
@testable import gdal_static_swift

class UnitTests: XCTestCase {

    let provider = TileProvider()
    let bundle = Bundle.module
    let coordinates = TileCoordinates(x: 19747, y: 11083, z: 15)

    func testBounds() {
        let bounds = Bounds(x: 19747, y: 11083, z: 15)

        XCTAssertEqual(bounds.min.x, 4112923.617968764)
        XCTAssertEqual(bounds.min.y, -6483082.99103551)
        XCTAssertEqual(bounds.max.x, 4114146.610421326)
        XCTAssertEqual(bounds.max.y, -6481859.998582946)

        let transform =  bounds.transform
        XCTAssertEqual(transform[0], 4112923.617968764)
        XCTAssertEqual(transform[1], 4.777314267819747)
        XCTAssertEqual(transform[2], 0.0)
        XCTAssertEqual(transform[3], 6483082.99103551)
        XCTAssertEqual(transform[4], 0.0)
        XCTAssertEqual(transform[5], -4.777314267819747)
    }

    func testColor() {
        let hex = Color(hex: 0xFF00FF)

        XCTAssertEqual(hex.red, 255)
        XCTAssertEqual(hex.green, 0)
        XCTAssertEqual(hex.blue, 255)
        XCTAssertEqual(hex.alpha, 255)
        XCTAssertEqual(hex.bitmap, [255, 0, 255, 255])

        XCTAssertEqual(Color(hex: 0x0, alpha: 255).bitmap, [0, 0, 0, 0])
        XCTAssertEqual(Color.clear.alpha, 0)
    }

    func testColorHSV() {

        // swiftlint:disable identifier_name
        func hsv(hue: UInt16, r: UInt8, g: UInt8, b: UInt8) {
        // swiftlint:enable identifier_name
            let hsv = Color(hue: hue, saturation: 1, value: 1)
            XCTAssertEqual(hsv.red, r)
            XCTAssertEqual(hsv.green, g)
            XCTAssertEqual(hsv.blue, b)
        }

        hsv(hue: 0, r: 255, g: 0, b: 0)
        hsv(hue: 60, r: 255, g: 255, b: 0)
        hsv(hue: 120, r: 0, g: 255, b: 0)
        hsv(hue: 180, r: 0, g: 255, b: 255)
        hsv(hue: 240, r: 0, g: 0, b: 255)
        hsv(hue: 300, r: 255, g: 0, b: 255)

        XCTAssertEqual(Color(hue: 14, saturation: 0, value: 1).bitmap, [255, 255, 255, 255])
    }

    func testColorNDVI() {
        XCTAssertEqual(Color.ndvi(-1).bitmap, [0, 0, 0, 0])
        XCTAssertEqual(Color.ndvi(0.04).bitmap, [66, 33, 18, 255])
        XCTAssertEqual(Color.ndvi(0.1).bitmap, [97, 49, 26, 255])
        XCTAssertEqual(Color.ndvi(0.25).bitmap, [182, 124, 31, 255])
        XCTAssertEqual(Color.ndvi(0.33).bitmap, [233, 220, 10, 255])
        XCTAssertEqual(Color.ndvi(0.359).bitmap, [248, 250, 3, 255])
        XCTAssertEqual(Color.ndvi(0.4354).bitmap, [214, 226, 1, 255])
        XCTAssertEqual(Color.ndvi(0.499).bitmap, [185, 207, 1, 255])
        XCTAssertEqual(Color.ndvi(0.5001).bitmap, [184, 206, 1, 255])
        XCTAssertEqual(Color.ndvi(0.58).bitmap, [147, 181, 0, 255])
        XCTAssertEqual(Color.ndvi(0.62).bitmap, [128, 169, 0, 255])
        XCTAssertEqual(Color.ndvi(0.66).bitmap, [109, 156, 0, 255])
        XCTAssertEqual(Color.ndvi(0.74).bitmap, [73, 131, 0, 255])
        XCTAssertEqual(Color.ndvi(0.79).bitmap, [49, 115, 0, 255])
        XCTAssertEqual(Color.ndvi(0.833).bitmap, [39, 101, 29, 255])
        XCTAssertEqual(Color.ndvi(0.867).bitmap, [31, 91, 45, 255])
        XCTAssertEqual(Color.ndvi(0.968).bitmap, [6, 60, 14, 255])
        XCTAssertEqual(Color.ndvi(1.001).bitmap, [0, 50, 0, 255])
    }

    func testColorContrast() {
        XCTAssertEqual(Color.contrast(0.4, min: 0.133, max: 0.8).bitmap, [132, 255, 50, 255])
        XCTAssertEqual(Color.contrast(0.5687, min: 0.133, max: 0.8).bitmap, [50, 255, 173, 255])
        XCTAssertEqual(Color.contrast(0.133, min: 0.133, max: 0.8).bitmap, [255, 0, 0, 255])
        XCTAssertEqual(Color.contrast(0.80, min: 0.133, max: 0.8).bitmap, [0, 0, 255, 255])
        XCTAssertEqual(Color.contrast(-1, min: 0.133, max: 0.8).bitmap, [0, 0, 0, 0])
    }

    func testVisual() {
        guard let path = self.bundle.path(forResource: "visual", ofType: "tif") else {
            XCTFail("Can't find file")
            return
        }

        guard let tilePath = self.bundle.path(forResource: "visual_tile", ofType: "base64") else {
            XCTFail("Can't find file")
            return
        }

        let coordinates = TileCoordinates(x: 39501, y: 22163, z: 16)

        do {
            let tile = try self.provider.visible(path: path, coordinates: coordinates)

            let tileBase64 = try String(contentsOfFile: tilePath)

            XCTAssertEqual(tile.count, 43594)
            XCTAssertEqual(tile.base64EncodedString(), tileBase64.replacingOccurrences(of: "\n", with: ""))
        } catch let error {
            XCTFail("error - \(error)")
        }
    }

    func testNDVI_Int() {
        guard let path = self.bundle.path(forResource: "ndvi_int", ofType: "tif") else {
            XCTFail("Can't find file")
            return
        }

        guard let tilePath = self.bundle.path(forResource: "ndvi_int_tile", ofType: "base64") else {
            XCTFail("Can't find file")
            return
        }

        do {
            let tile = try self.provider.ndvi(path: path, coordinates: self.coordinates)

            let tileBase64 = try String(contentsOfFile: tilePath)

            XCTAssertEqual(tile.count, 59926)
            XCTAssertEqual(tile.base64EncodedString(), tileBase64.replacingOccurrences(of: "\n", with: ""))
        } catch let error {
            XCTFail("error - \(error)")
        }
    }

    func testNDVI_Float() {
        guard let path = self.bundle.path(forResource: "ndvi_float", ofType: "tif") else {
            XCTFail("Can't find file")
            return
        }

        guard let tilePath = self.bundle.path(forResource: "ndvi_float_tile", ofType: "base64") else {
            XCTFail("Can't find file")
            return
        }

        do {
            let tile = try self.provider.ndvi(path: path, coordinates: self.coordinates)

            let tileBase64 = try String(contentsOfFile: tilePath)

            XCTAssertEqual(tile.count, 59930)
            XCTAssertEqual(tile.base64EncodedString(), tileBase64.replacingOccurrences(of: "\n", with: ""))
        } catch let error {
            XCTFail("error - \(error)")
        }
    }

    func testContrast_Int() {
        guard let path = self.bundle.path(forResource: "ndvi_int", ofType: "tif") else {
            XCTFail("Can't find file")
            return
        }

        guard let tilePath = self.bundle.path(forResource: "contrast_int_tile", ofType: "base64") else {
            XCTFail("Can't find file")
            return
        }

        do {
            let tile = try self.provider.contrast(path: path, coordinates: self.coordinates)

            let tileBase64 = try String(contentsOfFile: tilePath)

            XCTAssertEqual(tile.count, 57767)
            XCTAssertEqual(tile.base64EncodedString(), tileBase64.replacingOccurrences(of: "\n", with: ""))
        } catch let error {
            XCTFail("error - \(error)")
        }
    }

    func testContrast_Float() {
        guard let path = self.bundle.path(forResource: "ndvi_float", ofType: "tif") else {
            XCTFail("Can't find file")
            return
        }

        guard let tilePath = self.bundle.path(forResource: "contrast_float_tile", ofType: "base64") else {
            XCTFail("Can't find file")
            return
        }

        do {
            let tile = try self.provider.contrast(path: path, coordinates: self.coordinates)

            let tileBase64 = try String(contentsOfFile: tilePath)

            XCTAssertEqual(tile.count, 57795)
            XCTAssertEqual(tile.base64EncodedString(), tileBase64.replacingOccurrences(of: "\n", with: ""))
        } catch let error {
            XCTFail("error - \(error)")
        }
    }

    static var allTests = [
        ("testBounds", testBounds)
    ]
}
