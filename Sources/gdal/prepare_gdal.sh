#!/bin/sh

GDAL=Sources/gdal

echo "Clean"
rm -f gdal.xcframework.zip
rm -rf $GDAL/gdal.xcframework

echo "Gdal union"
curl -L -O  https://github.com/Lumyk/gdal/releases/download/1.0/gdal.xcframework.zip
unzip gdal.xcframework.zip -d $GDAL
