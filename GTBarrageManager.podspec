Pod::Spec.new do |s|
  s.name         = "GTBarrageManager"
  s.version      = "0.0.1"
  s.summary      = “Beyond  of the best GTBarrageManager."

  s.description  = <<-DESC
			After announced Swift, ReactiveCocoa was rewritten in Swift. This framework creates a bridge between those Swift and Objective-C APIs (ReactiveSwift and ReactiveObjC).
    Because the APIs are based on fundamentally different designs, the conversion is not always one-to-one; however, every attempt has been made to faithfully translate the concepts between the two APIs (and languages).
                   DESC

  s.homepage     = "https://github.com/Maybeyourdad/GTBarrageManager"


  #s.license      = "MIT (example)"
   s.license      = { :type => "MIT", :file => "LICENSE.md” }

  s.author             = { “Maybeyourdad” => “1027320210@qq.com" }

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
   s.ios.deployment_target = “7.0”
   s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Maybeyourdad/GTBarrageManager.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

 
end
