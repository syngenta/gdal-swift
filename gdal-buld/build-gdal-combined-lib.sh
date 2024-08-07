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

architectures=("arm64" "x86_64")

# Building for device
for f in "arm64"; do
    echo Building $f for device
    ./build_gdal_ios.sh -p ${PREFIX} -a $f device 2>&1 | tee "${LOG}/${f}.txt"
done

# Building for simulator
for f in "${architectures[@]}"; do
    echo Building $f for simulator
    ./build_gdal_ios.sh -p ${PREFIX} -a $f simulator 2>&1 | tee "${LOG}/simulator_${f}.txt"
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
    -library ${PREFIX}/x86_64/iphonesimulator${SDK_VERSION}.sdk/lib/libgdal_proj.a \
        -headers ${PREFIX}/x86_64/iphonesimulator${SDK_VERSION}.sdk/include \
    -output gdal.xcframework

# Zipping GDAL for upload
zip -r gdal.xcframework.zip gdal.xcframework

echo "Almost done! On the next step you should upload gdal.xcframework.zip to GitHub Releases https://github.com/syngenta/gdal-swift/releases"
