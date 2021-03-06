Pod::Spec.new do |spec|
  spec.name             = 'DRAsyncOperations'
  spec.version          = '1.0.1'
  spec.license          = { :type => 'MIT' }
  spec.summary          = 'Implementation of a concurrent NSOperation to abstract and help the creation of asynchronous operations.'
  spec.homepage         = 'https://github.com/dmcrodrigues/DRAsyncOperations'
  spec.authors          = { 'David Rodrigues' => 'https://twitter.com/dmcrodrigues' }
  spec.source           = { :git => 'https://github.com/dmcrodrigues/DRAsyncOperations.git', :tag => spec.version.to_s }
  spec.requires_arc     = true

  spec.public_header_files  = 'DRAsyncOperations/DRAsyncOperations.h'
  spec.source_files         = 'DRAsyncOperations/*.{h,m}'

  spec.ios.deployment_target      = '7.0'
  spec.osx.deployment_target      = '10.9'
  spec.watchos.deployment_target  = '2.0'
  spec.tvos.deployment_target     = '9.0'
end
