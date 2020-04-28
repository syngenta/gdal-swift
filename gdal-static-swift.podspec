#
# Be sure to run `pod lib lint gdal-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'gdal-static-swift'
  s.version          = `git describe --abbrev=0 --tags`
  s.summary          = 'GDAL static library'
  s.description      = "This is GDAL static library builded for ios platform, with swift binding"

  s.homepage         = 'https://github.com/cropio/gdal-static-swift'
  s.author           = { 'Evgeny Kalashnikov' => 'lumyk@me.com' }
  s.source           = { :git => 'git@github.com:cropio/gdal-static-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.prepare_command = "sh Sources/gdal/prepare_gdal.sh"

  s.source_files = 'Sources/*.swift', 'Sources/gdal/include/*.h', 'Sources/TileProvider/*.swift'
  s.private_header_files = 'Sources/gdal/include/*.h'
  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Sources/gdal/**',
    'LIBRARY_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/Sources/',
    'VALID_ARCHS' => 'x86_64 armv7 arm64'
  }

  s.libraries = 'c++', 'sqlite3', 'z'

  s.preserve_paths  = 'Sources/gdal/module.modulemap'
  s.vendored_libraries = 'Sources/gdal/libproj.a','Sources/gdal/libgdal.a'

end
