#!/bin/sh

GDAL=Sources/gdal
# This URL should be updated after GDAL recompile
URL=https://github.com/syngenta/gdal-swift/releases/download/gdal-builds/gdal_1.0.1.xcframework.zip

echo "Clean"
rm -f gdal.xcframework.zip
rm -rf $GDAL/gdal.xcframework

echo "GDAL downloading"
curl -L -O $URL
unzip gdal.xcframework.zip -d $GDAL
