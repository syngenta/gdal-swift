#!/bin/sh

GDAL=Sources/gdal
# This URL should be updated after GDAL recompile
URL=https://github.com/syngenta/gdal-swift/releases/download/1.0.0/gdal.xcframework.zip

echo "Clean"
rm -f gdal.xcframework.zip
rm -rf $GDAL/gdal.xcframework

echo "GDAL downloading"
curl -L -O $URL
unzip gdal.xcframework.zip -d $GDAL
