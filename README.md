# gdal-static-swift
[![Build Status](https://travis-ci.com/cropio/gdal-static-swift.svg?token=2x1gjKbRpPVj3abdDxFe&branch=master)](https://travis-ci.com/cropio/gdal-static-swift) [![codecov](https://codecov.io/gh/cropio/gdal-static-swift/branch/master/graph/badge.svg?token=79emLU9lm3)](https://codecov.io/gh/cropio/gdal-static-swift) [![Maintainability](https://api.codeclimate.com/v1/badges/14c3a11bb64cf09f9317/maintainability)](https://codeclimate.com/repos/5ea6c2f7644a6501a300d6bc/maintainability)

This is GDAL static library builded for ios platform, with swift binding

### Installation
For installation GDAL you can use cocoapods

```ruby
pod 'gdal-swift-static'
```

For using pods you need to add custom source
```ruby
source 'https://github.com/cropio/cocoapods-specs.git'
```

### TileProvider
Class for getting tiles from visual and NDVI **tif** files

```swift
let provider = TileProvider()

guard let path = Bundle.main.path(forResource: "file", ofType: "tif") else {
    return
}

let coordinates = TileCoordinates(x: 19747, y: 11083, z: 15)

do {
    // tileSize by default 256
    let data = try provider.visible(path: path, coordinates: coordinates, tileSize: 256)
    print(data) // tile in Data type
} catch let error {
    print(error)
}
```

### Demo
For running **Demo** run commands:
```shell
cd Demo
pod install
```

### GDAL static library compilation
For compilation gdal static library run this commands:

```shell
cd gdal-buld
./build-gdal-combined-lib.sh
```

After success compilation you will found **gdal.xcframework** in folder.

For using gdal with **static framework** you need to copy gdal parts (gdal-buld/parts) to **Sources/gdal/lib**

Run this script for copy parts (Old parts will be removed)
```shell
./copy_parts.sh
```
