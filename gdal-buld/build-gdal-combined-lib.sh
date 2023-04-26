#!/bin/bash
PREFIX=`pwd`/install
rm -rf $PREFIX
mkdir $PREFIX
LOG=./log
rm -rf $LOG
mkdir $LOG

if [ -e ${PREFIX} ]
then
	echo removing ${PREFIX}
	rm -rf ${PREFIX}
fi

mkdir ${PREFIX}

for f in "arm64"; do
echo Building $f
./build_gdal_ios.sh -p ${PREFIX} -a $f device 2>&1 | tee "${LOG}/${f}.txt"
done

echo Building simulator
for f in "arm64"; do
echo Building $f
./build_gdal_ios.sh -p ${PREFIX} -a $f simulator 2>&1 | tee "${LOG}/simulator.txt"
done

SDK_VERSION=13.0

# Making xcframework for gdal
rm -f gdal.xcframework.zip
rm -rf gdal.xcframework
xcodebuild -create-xcframework \
    -library ${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/lib/libgdal_proj.a \
		-headers ${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/include \
    -library ${PREFIX}/arm64/iphonesimulator${SDK_VERSION}.sdk/lib/libgdal_proj.a \
		-headers ${PREFIX}/arm64/iphonesimulator${SDK_VERSION}.sdk/include \
    -output gdal.xcframework

# Ziping GDAL for split
zip -r gdal.xcframework.zip gdal.xcframework

# Spliting GDAL for github
rm -rf parts
mkdir parts
split -b 50m "gdal.xcframework.zip" "parts/gdal.part."

echo "Almost done! For copy xcframework parts to Sources folder just run './copy_parts.sh'"
