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
for f in "arm64" "x86_64"; do
echo Building $f
./build_gdal_ios.sh -p ${PREFIX} -a $f simulator 2>&1 | tee "${LOG}/simulator_${f}.txt"
done

SDK_VERSION=13.0

# Create universal (fat) simulator library from arm64 + x86_64
SIMULATOR_UNIVERSAL=${PREFIX}/simulator_universal
mkdir -p ${SIMULATOR_UNIVERSAL}/lib
cp -r ${PREFIX}/arm64/iphonesimulator${SDK_VERSION}.sdk/include ${SIMULATOR_UNIVERSAL}/include
lipo -create \
    ${PREFIX}/arm64/iphonesimulator${SDK_VERSION}.sdk/lib/libgdal_proj.a \
    ${PREFIX}/x86_64/iphonesimulator${SDK_VERSION}.sdk/lib/libgdal_proj.a \
    -output ${SIMULATOR_UNIVERSAL}/lib/libgdal_proj.a

# Making xcframework for gdal
rm -f gdal.xcframework.zip
rm -rf gdal.xcframework
xcodebuild -create-xcframework \
    -library ${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/lib/libgdal_proj.a \
		-headers ${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/include \
    -library ${SIMULATOR_UNIVERSAL}/lib/libgdal_proj.a \
		-headers ${SIMULATOR_UNIVERSAL}/include \
    -output gdal.xcframework

# Copy proj.db to Sources for SPM resource bundling
cp ${PREFIX}/arm64/iphoneos${SDK_VERSION}.sdk/share/proj/proj.db ../Sources/proj.db
echo "Updated Sources/proj.db"

# Ziping GDAL for split
zip -r gdal.xcframework.zip gdal.xcframework

echo "Almost done! On the next step You should upload gdal.xcframework.zip to Githab Releases https://github.com/syngenta/gdal-swift/releases"
