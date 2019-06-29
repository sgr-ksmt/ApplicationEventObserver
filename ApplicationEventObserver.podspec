Pod::Spec.new do |s|

  s.name         = "ApplicationEventObserver"
  s.version      = "2.0"
  s.summary      = "Application event notification (e.g. UIApplicationDidBecomeActiveNotification) handling in Swift."

  s.description  = <<-DESC
                    Application event notification (e.g. UIApplicationDidBecomeActiveNotification) handling in Swift.
                    You don't have to use `NSNotificationCenter`.
                   DESC

  s.homepage = "https://github.com/sgr-ksmt/ApplicationEventObserver"

  s.license = "MIT"

  s.author = "Suguru Kishimoto"

  s.platform = :ios, "10.0"
  s.ios.deployment_target = "10.0"
  s.swift_version = "5.0"
  s.source = { :git => "https://github.com/sgr-ksmt/ApplicationEventObserver.git", :tag => s.version.to_s }
  s.source_files  = "ApplicationEventObserver/**/*.swift"
end
