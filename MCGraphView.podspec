Pod::Spec.new do |s|
  s.name     = 'MCGraphView'
  s.version  = '0.1.1'
  s.ios.deployment_target   = '6.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A light-weight solution for displaying graphs.'
  s.homepage = 'https://github.com/matthewcheok/MCGraphView'
  s.author   = { 'Matthew Cheok' => 'cheok.jz@gmail.com' }
  s.requires_arc = true
  s.source   = {
    :git => 'https://github.com/matthewcheok/MCGraphView.git',
    :branch => 'master',
    :tag => s.version.to_s
  }
  s.source_files = 'MCGraphView/*.{h,m}'
  s.public_header_files = 'MCGraphView/*.h'
end
