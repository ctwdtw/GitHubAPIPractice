install! 'cocoapods', :warn_for_unused_master_specs_repo => false

platform :ios, '13.0'
#use_frameworks!

workspace 'GitHubAPIPractice'
#project 'GitHubAPIApp/GitHubAPIApp'
#project 'GitHubAPI/GitHubAPI'

def shared_pod
  
end

target 'GitHubAPIApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  project 'GitHubAPIApp/GitHubAPIApp'
  shared_pod
  #pod 'SnapKit'
end

target 'GitHubAPIAppTests' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  project 'GitHubAPIApp/GitHubAPIApp'
  shared_pod
  #pod 'SnapKit'
end

target 'GitHubAPI' do
 # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
 use_frameworks!
 project 'GitHubAPI/GitHubAPI'
 shared_pod
 pod 'Alamofire'
 pod 'Nuke', '9.5.0'
end

target 'GitHubAPITests' do
 # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
 use_frameworks!
 project 'GitHubAPI/GitHubAPI'
 shared_pod
 pod 'Alamofire'
 pod 'Nuke', '9.5.0'
end

