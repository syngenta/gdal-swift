#!/bin/bash
set -u

default_iphoneos_version=13.0
default_architecture=arm64

export IPHONEOS_DEPLOYMENT_TARGET="${IPHONEOS_DEPLOYMENT_TARGET:-$default_iphoneos_version}"
DEFAULT_ARCHITECTURE="${DEFAULT_ARCHITECTURE:-$default_architecture}"
DEFAULT_PREFIX="${HOME}/Desktop/iOS_GDAL"


usage ()
    {
cat >&2 << EOF
    Usage: ${0} [-h] [-p prefix] [-a arch] target [configure_args]
        -h  Print help message
        -p  Installation prefix (default: \$HOME/Documents/iOS_GDAL...)
        -a  Architecture target for compilation (default: armv7)

    The target must be "device" or "simulator".  Any additional arguments
    are passed to configure.

    The following environment variables affect the build process:

        IPHONEOS_DEPLOYMENT_TARGET  (default: $default_iphoneos_version)
        DEFAULT_PREFIX  (default: $default_prefix)
EOF
    }

prefix="${DEFAULT_PREFIX}"

while getopts ":hp:a:" opt; do
        case $opt in
        h  ) usage ; exit 0 ;;
        p  ) prefix="$OPTARG" ;;
        a  ) DEFAULT_ARCHITECTURE="$OPTARG" ;;
        \? ) usage ; exit 2 ;;
        esac
done
shift $(( $OPTIND - 1 ))

if (( $# < 1 )); then
    usage
    exit 2
fi

target=$1
shift

case $target in

        device )
        arch="${DEFAULT_ARCHITECTURE}"
        platform=iphoneos
        extra_cflags=" "
        ;;

        simulator )
        arch="${DEFAULT_ARCHITECTURE}"
        platform=iphonesimulator
        extra_cflags="-D__IPHONE_OS_VERSION_MIN_REQUIRED=${IPHONEOS_DEPLOYMENT_TARGET%%.*}0000"
        ;;

        * )
        echo No target found!!!
        usage
        exit 2

esac
if [ $arch = "arm64" ]
then
      if [ $platform = "iphonesimulator" ]
      then
        host="aarch64-apple-darwin"
      else
        host="arm-apple-darwin"
      fi
else
    host="${arch}-apple-darwin"
fi

echo "building for host ${host}"

platform_dir=`xcrun -find -sdk ${platform} --show-sdk-platform-path`
platform_sdk_dir=`xcrun -find -sdk ${platform} --show-sdk-path`
prefix="${prefix}/${arch}/${platform}${IPHONEOS_DEPLOYMENT_TARGET}.sdk"

echo
echo library will be exported to $prefix

#setup compiler flags
 # export CC=`xcrun -find -sdk iphoneos gcc`
export CFLAGS="-I/opt/local/include -fembed-bitcode -Wno-error=implicit-function-declaration -arch ${arch} -pipe -Os -gdwarf-2 -isysroot ${platform_sdk_dir} ${extra_cflags}"
export LDFLAGS="-arch ${arch} -isysroot ${platform_sdk_dir}"
 # export CXX=`xcrun -find -sdk iphoneos g++`
export CXXFLAGS="${CFLAGS}"
 # export CPP=`xcrun -find -sdk iphoneos cpp`
 # export CXXCPP="${CPP}"

 export CC=$(xcrun -find clang)
 export CXX=$(xcrun -find clang++)

echo CFLAGS ${CFLAGS}

export MACOSX_DEPLOYMENT_TARGET=13

#set proj4 install destination
proj_prefix=$prefix
proj_version=6.3.2 #4.9.3
echo install proj to $proj_prefix

rm -rf proj-$proj_version

#download proj4 if necesary
if [ ! -e proj-$proj_version.tar.gz ]
then
    echo proj4 missing, downloading
    wget http://download.osgeo.org/proj/proj-$proj_version.tar.gz
fi

tar -xzf proj-$proj_version.tar.gz

#configure and build proj4
pushd proj-$proj_version

echo
echo "cleaning proj"
make clean

echo
echo "configure proj"
./configure \
    --prefix=${proj_prefix} \
    --enable-shared=no \
    --enable-static=yes \
    --host=$host \
    --disable-dependency-tracking \
    "$@" || exit

echo
echo "make install proj"
time make -j
time make install || exit

popd

#Remove DEBUG information from file
strip -S ${proj_prefix}/lib/libproj.a

gdal_version=3.5.3 #1.11.5

rm -rf gdal-$gdal_version
#download gdal if necesary
if [ ! -e gdal-$gdal_version.tar.gz ]
then
    wget http://download.osgeo.org/gdal/$gdal_version/gdal-$gdal_version.tar.gz
fi

tar -xzf gdal-$gdal_version.tar.gz
#configure and build gdal
cd gdal-$gdal_version

#Fix problem with compilation
input_file="ogr/ogrsf_frmts/sqlite/ogrsqlitedatasource.cpp"
output_file="ogr/ogrsf_frmts/sqlite/ogrsqlitedatasource.cpp"
echo '#define sqlite3_enable_load_extension(x,y) SQLITE_OK' >> temp.txt
echo '#define sqlite3_load_extension(db, ext, s, err) SQLITE_OK' >> temp.txt
cat "$input_file" >> temp.txt
mv temp.txt "$output_file"

echo "cleaning gdal"
make clean

echo
echo "configure gdal"
./configure \
--prefix="${prefix}" \
--host=$host \
--disable-shared \
--enable-static \
--with-hide-internal-symbols=yes \
--with-unix-stdio-64=no \
--without-libiconv-prefix \
--with-pg=no \
--with-python=no \
--with-java=no \
--with-threads=yes \
--with-docs=no \
--with-proj=${proj_prefix} \
--with-sqlite3=${platform_sdk_dir} \
--disable-all-optional-drivers \
--with-geos=no \
--without-jpeg12 \
--with-hdfs=no \
--without-pcidsk \
--without-gif \
--without-ogdi \
--without-hdf4 \
--without-hdf5 \
--without-netcdf \
--without-odbc \
--without-cfitsio \
--without-ecw \
--without-kakadu \
--without-mrsid \
--without-jp2mrsid \
--without-mysql \
--without-xerces \
--without-expat \
--without-libkml \
--without-spatialite \
--without-idb \
--without-python \
--without-oci \
--without-sosi \
--without-qhull \
--without-freexl \
--without-poppler \
--without-podofo \
--without-rasdaman \
--without-armadillo \
--without-crypto \
--without-curl \
--without-xml2 \
--without-openjpeg \
--without-webp \
--without-zstd \
--without-pg \
--without-gnm \
--with-sse=no \
--with-ssse3=no \
--with-avx=no \
--with-liblzma=no \
--with-zstd=no \
--with-blosc=no \
--with-lz4=no \
--with-pg=no \
--with-cfitsio=no \
--with-pcraster=no \
--with-png=no \
--with-dds=no \
--with-gta=no \
--with-gif=no \
--with-sosi=no \
--with-mongocxxv3=no \
--with-netcdf=no \
--with-fgdb=no \
--with-ecw=no \
--with-mrsid=no \
--with-jp2mrsid=no \
--with-msg=no \
--with-oci=no \
--with-odbc=no \
--with-xml2=no \
--with-webp=no \
--with-geos=no \
--with-sfcgal=no \
--with-qhull=no \
--with-freexl=no \
--with-python=no \
--with-hdfs=no \
--with-rdb=no \
--with-cryptopp=no \
--with-crypto=no \
|| exit

echo
echo "building gdal"
time make -j

echo
echo "installing"
time make install

#Remove DEBUG information from file
strip -S ${prefix}/lib/libgdal.a

cd ..
echo "Gdal build complete"

#Combyne libraries gdal and proj (device)
libtool -static -o ${prefix}/lib/libgdal_proj.a ${prefix}/lib/libproj.a ${prefix}/lib/libgdal.a

#Copy modulemap file
cp module.modulemap ${prefix}/include/
