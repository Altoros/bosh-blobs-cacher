Gem::Specification.new do |s|
  s.name        = 'bosh-syncer'
  s.version     = '0.0.0'
  s.date        = '2014-10-26'
  s.summary     = "BOSH CLI plugin to automate working with blobstore and releases."
  s.description = "BOSH CLI plugin"
  s.authors     = ["Alexander Lomov"]
  s.email       = 'lomov.as@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*")
  s.homepage    = 'http://rubygems.org/gems/bosh-syncer'
  s.license     = 'MIT'
  s.add_runtime_dependency 'bosh_cli', '~> 1.2754.0'
  s.add_runtime_dependency 'git', '~> 1.2.8'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'  
end
