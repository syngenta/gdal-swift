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

for f in "armv7" "armv7s" "arm64"; do
echo Building $f
./build_gdal_ios.sh -p ${PREFIX} -a $f device 2>&1 | tee "${LOG}/${f}.txt"
done

echo Building simulator
for f in "x86_64"; do
echo Building $f
./build_gdal_ios.sh -p ${PREFIX} -a $f simulator 2>&1 | tee "${LOG}/simulator.txt"
done


SDK_VERSION=10.0

lipo \
${PREFIX}/x86_64/iphonesimulator${SDK_VERSION}.sdk/lib/libgdal.a \
${PREFIX}/armv7/iphoneos${SDK_VERSION}.sdk/lib/libgdal.a \
${PREFIX}/armv7s/iphoneos${SDK_VERSION}.sdk/lib/libgdal.a \
${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/lib/libgdal.a \
-output ${PREFIX}/libgdal.a \
-create

lipo \
${PREFIX}/x86_64/iphonesimulator${SDK_VERSION}.sdk/lib/libproj.a \
${PREFIX}/armv7/iphoneos${SDK_VERSION}.sdk/lib/libproj.a \
${PREFIX}/armv7s/iphoneos${SDK_VERSION}.sdk/lib/libproj.a \
${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/lib/libproj.a \
-output ${PREFIX}/libproj.a \
-create

# Copy files to GDAL folder
cd ${PREFIX}
mkdir GDAL
cp libgdal.a ${PREFIX}/libproj.a GDAL
cp -R arm64/iphoneos10.0.sdk/include GDAL

# Ziping GDAL for split
cd GDAL
zip libgdal.a.zip libgdal.a

# Spliting GDAL for github
mkdir parts
split -b 50m "libgdal.a.zip" "parts/libgdal.part."

open .
