Pod::Spec.new do |s|

  s.name         = "ZTInputBox"
  s.version      = "0.0.1"
  s.summary      = "SnapKit 简单封装，并自定义操作符"

  s.homepage     = "https://github.com/zt-zhang/ZTInputBox.git"
  s.author       = { "T_T" => "zt_zhang@protonmail.com" }
  s.source       = { :git => "https://github.com/zt-zhang/ZTInputBox.git", :tag => s.version }
  
  s.platform     = :ios, "10.0"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.source_files = "ZTInputBox/ZTInputBox/**/*.swift"
  s.framework    = "UIKit","Foundation"
  s.requires_arc = true

  s.dependency 'SnapKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'IQKeyboardManagerSwift'

end
