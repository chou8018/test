#Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
inhibit_all_warnings!
use_frameworks!

def pods
  
  pod 'IQKeyboardManagerSwift'
  pod 'EmptyDataSet-Swift'
  pod "ESPullToRefresh"
  pod 'TLPhotoPicker'
  pod 'Alamofire', '~> 4.8.2'
  pod 'AlamofireImage', '~> 3.5'
  pod 'SnapKit'
  pod 'PromiseKit', '~> 6.8'
  pod 'Swinject'
  pod 'KeychainAccess'
  pod 'FMDB'
  pod 'Siren'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/RemoteConfig'

end

target 'ClaimApp' do
  use_frameworks!
  pods
end

target 'ClaimAppStaging' do
  use_frameworks!
  pods
  
  target 'ClaimAppStagingTests' do
     inherit! :search_paths
  end
end
