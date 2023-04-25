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

  s.ios.deployment_target = '13.0'

  s.prepare_command = "sh Sources/gdal/prepare_gdal.sh"
  s.source_files = 'Sources/*.swift', 'Sources/TileProvider/*.swift'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64' }
  s.xcconfig = { 'OTHER_LDFLAGS' => '-liconv' }
  s.libraries = 'c++', 'sqlite3', 'z', 'xml2'
  s.vendored_frameworks = 'Sources/gdal/gdal.xcframework'

end
