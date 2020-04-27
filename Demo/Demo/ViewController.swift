//
//  ViewController.swift
//  Demo
//
//  Created by Evegeny Kalashnikov on 6/20/19.
//  Copyright © 2019 Evegeny Kalashnikov. All rights reserved.
//

import UIKit
import gdal_static_swift

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    let tile = TileProvider()
    let coordinates = TileCoordinates(x: 19747, y: 11083, z: 15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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



