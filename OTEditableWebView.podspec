Pod::Spec.new do |s|
  s.name         = "OTEditableWebView"
  s.version      = "0.0.1"
  s.summary      = "Make UIWebView content editable."
  s.homepage     = "https://github.com/jgritman/OTEditableWebView"
  s.authors      = { 'OpenFibers' => 'openfibers@gmail.com' }
  s.source       = { :git => "https://github.com/jgritman/OTEditableWebView.git", :commit => "73d57dc645d74a29ae3fd5195231eee884d251ff" }
  s.source_files = 'OTEditableWebView/**/*.{h,m}'
end
