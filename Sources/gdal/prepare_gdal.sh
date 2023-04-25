#!/bin/sh

GDAL=Sources/gdal
GDAL_LIB=Sources/gdal/lib

echo "Clean"
rm -f $GDAL_LIB/gdal.xcframework.zip
rm -f $GDAL/gdal.xcframework

echo "Gdal union"
cat $GDAL_LIB/gdal.part.* > $GDAL_LIB/gdal.xcframework.zip
unzip $GDAL_LIB/gdal.xcframework.zip -d $GDAL
