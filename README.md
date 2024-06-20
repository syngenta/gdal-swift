# gdal-static-swift
[![Build Status](https://travis-ci.com/cropio/gdal-static-swift.svg?token=2x1gjKbRpPVj3abdDxFe&branch=master)](https://travis-ci.com/cropio/gdal-static-swift) [![codecov](https://codecov.io/gh/cropio/gdal-static-swift/branch/master/graph/badge.svg?token=79emLU9lm3)](https://codecov.io/gh/cropio/gdal-static-swift) [![Maintainability](https://api.codeclimate.com/v1/badges/14c3a11bb64cf09f9317/maintainability)](https://codeclimate.com/repos/5ea6c2f7644a6501a300d6bc/maintainability)

This is GDAL static library builded for ios platform, with swift binding

### Installation
For installation GDAL you can use **Swift Package Manager** or **Cocoapods**

#### Swift Package Manager
Use Xcode menu **File -> Add Package Dependencies...** and add this repository url in search field.
```url
https://github.com/cropio/gdal-static-swift.git
```

#### Cocoapods
```ruby
pod 'gdal-swift-static', :git => 'https://github.com/cropio/gdal-static-swift.git'
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
open Demo.xcodeproj
```

### GDAL static library compilation
For compilation gdal static library run this commands:

```shell
cd gdal-buld
./build-gdal-combined-lib.sh
```

After success compilation you will find **gdal.xcframework.zip** file in **gdal-buld** folder.

Then you should upload this file to [**Releases**](https://github.com/cropio/gdal-static-swift/releases) section in this repository.
```
// **url** example
https://github.com/cropio/gdal-static-swift/releases/download/1.0.0/gdal.xcframework.zip
```

After uploading you need to change **url** of this file in two files  **Package.swift** and **prepare_gdal.sh**
  
#### **Package.swift**
File located in root folder. You need to change **url** and **checksum** in this file.

For caclulation checksum you can use this command:
```shell
swift package compute-checksum gdal.xcframework.zip
```

#### **prepare_gdal.sh**
File located in **Sources/gdal/** folder. You need to change **url** in this file.
