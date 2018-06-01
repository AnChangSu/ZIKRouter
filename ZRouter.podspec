Pod::Spec.new do |s|

  s.name         = "ZRouter"
  s.version      = "1.0.1"
  s.summary      = "Interface-Oriented iOS Swift router for discovering modules and injecting dependencies with protocol."
  s.description  = <<-DESC
                Interface-Oriented iOS Swift router for discovering modules and injecting dependencies with protocol, designed for VIPER. The view router can perform all navigation types in UIKit through one method. The service router can discover service with protocol.
                   DESC
  s.homepage         = "https://github.com/Zuikyo/ZIKRouter"
  s.license      = "MIT"
  s.author             = { "Zuikyo" => "zuikxyo@gmail.com" }

  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.swift_version = "4.0"

  s.source       = { :git => "https://github.com/Zuikyo/ZIKRouter.git", :tag => "swift-#{s.version}" }

  s.source_files  = "ZRouter/*.swift"

  s.requires_arc = true

  s.dependency "ZIKRouter", '>= 1.0.1'

end
