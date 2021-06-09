#
#  Be sure to run `pod spec lint FileControlKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name             = "FileControlKit"
  spec.version          = "1.0.0"
  spec.summary          = "本地沙盒文件浏览与管理"
  spec.description      = "本地沙盒文件浏览与管理,方便浏览沙盒文件以及选择或删除"
  spec.homepage         = "https://www.jianshu.com/u/cd395981b31d"
  #spec.screenshots     = ""
  spec.license          = { :type => "GNU General Public License v3.0", :file => "LICENSE" }
  spec.author           = { "ZYiDa" => "468466882@qq.com" }
  spec.platform         = :ios, "11.0"
  spec.swift_versions   = "5.0"
  spec.source           = { :git => "https://github.com/ZYiDa/FileControlKit.git", :tag => "#{spec.version}" }
  spec.source_files     = "FileControlKit/*.{swift}"
  spec.resources        = "FileControlKit/*.xcassets"
  spec.framework        = "UIKit"
  spec.requires_arc     = true
end
