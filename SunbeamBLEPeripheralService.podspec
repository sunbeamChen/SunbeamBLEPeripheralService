Pod::Spec.new do |s|
  s.name             = 'SunbeamBLEPeripheralService'
  s.version          = '0.1.0'
  s.summary          = 'SunbeamBLEPeripheralService - an ble peripheral service base on core bluetooth.'

  s.homepage         = 'https://github.com/sunbeamChen/SunbeamBLEPeripheralService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sunbeamChen' => 'chenxun1990@126.com' }
  s.source           = { :git => 'https://github.com/sunbeamChen/SunbeamBLEPeripheralService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '7.0'
  s.source_files = 'SunbeamBLEPeripheralService/Classes/**/*'
  s.public_header_files = 'SunbeamBLEPeripheralService/Classes/**/*.h'
  s.frameworks = 'CoreBluetooth'
end
