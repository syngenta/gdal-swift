//
//  ViewController.swift
//  Demo
//
//  Created by Evegeny Kalashnikov on 6/20/19.
//  Copyright © 2019 Evegeny Kalashnikov. All rights reserved.
//

import UIKit
import gdal_swift
import gdal

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    let tile = TileProvider()
    let coordinates = TileCoordinates(x: 19747, y: 11083, z: 15)

    override func viewDidLoad() {
        super.viewDidLoad()
        testProjDB()
    }

    private func testProjDB() {
        let wgs84 = OSRNewSpatialReference(nil)
        let utm = OSRNewSpatialReference(nil)

        let wgs84Result = OSRSetWellKnownGeogCS(wgs84, "WGS84")
        let utmResult = OSRImportFromEPSG(utm, 32637) // UTM zone 37N

        if wgs84Result != OGRERR_NONE || utmResult != OGRERR_NONE {
            print("[proj.db TEST] FAILED: Cannot create spatial references (wgs84: \(wgs84Result), utm: \(utmResult))")
            return
        }

        guard let transform = OCTNewCoordinateTransformation(wgs84, utm) else {
            print("[proj.db TEST] FAILED: Cannot create coordinate transformation (proj.db is missing or wrong version)")
            return
        }

        var x = 36.0 // longitude
        var y = 50.0 // latitude
        var z = 0.0

        if OCTTransform(transform, 1, &x, &y, &z) == 1 {
            print("[proj.db TEST] SUCCESS: WGS84 (36.0, 50.0) -> UTM 37N (\(x), \(y))")
        } else {
            print("[proj.db TEST] FAILED: Coordinate transformation failed")
        }

        OCTDestroyCoordinateTransformation(transform)
        OSRDestroySpatialReference(wgs84)
        OSRDestroySpatialReference(utm)
    }
    
    @IBAction func visualAction() {
        
        guard let path = Bundle.main.path(forResource: "visual", ofType: "tif") else {
            return
        }
        
        do {
            let data = try self.tile.visible(path: path, coordinates: self.coordinates)
            self.imageView.image = UIImage(data: data)
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func ndviAction() {
        guard let path = Bundle.main.path(forResource: "ndvi_float", ofType: "tif") else {
            return
        }
        
        do {
            let data = try self.tile.ndvi(path: path, coordinates: self.coordinates)
            self.imageView.image = UIImage(data: data)
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func contrastAction() {
        guard let path = Bundle.main.path(forResource: "ndvi_int", ofType: "tif") else {
            return
        }

        do {
            let data = try self.tile.contrast(path: path, coordinates: self.coordinates)
            self.imageView.image = UIImage(data: data)
        } catch let error {
            print(error)
        }
    }
}



