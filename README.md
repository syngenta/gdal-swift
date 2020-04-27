# gdal-static-swift

This is GDAL static library builded for ios platform, with swift binding

### Installation
For installation GDAL you can use cocoapods

```
pod 'gdal-swift-static'
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

After success compilation you will found **libgdal.a** and **libproj.a** in **install/GDAL** folder.

For using gdal with **static framework** you need to copy gdal parts (gdal-buld/install/GDAL/parts) to **Sources/gdal/lib**

Removing old gdal parts
```shell
cd ..
rm -rf Sources/gdal/lib/*
```

Copy parts
```shell
cp gdal-buld/install/GDAL/parts/* Sources/gdal/lib
```

Removing headers
```shell
rm -rf Sources/gdal/include
```

Copy headers
```shell
cp -R gdal-buld/install/GDAL/include Sources/gdal/include
```

Copy proj
```shell
cp gdal-buld/install/GDAL/libproj.a Sources/gdal/libproj.a
```
