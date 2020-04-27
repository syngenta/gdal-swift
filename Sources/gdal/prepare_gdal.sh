#!/bin/sh

GDAL=Sources/gdal
GDAL_LIB=Sources/gdal/lib

echo "Clean"
rm -f $GDAL_LIB/libgdal.a.zip
rm -f $GDAL/libgdal.a

echo "Gdal union"
cat $GDAL_LIB/libgdal.part.* > $GDAL_LIB/libgdal.a.zip
unzip $GDAL_LIB/libgdal.a.zip -d $GDAL
