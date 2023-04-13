# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/autoscaling_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano3-aws-asg-deploy'
  spec.version       = Capistrano::AutoScalingDeploy::VERSION
  spec.authors       = ['Maxim Baibakov']
  spec.email         = ['maxim.baibakov@gmail.com']
  spec.summary       = %q{Deploy to AWS Auto Scaling group.}
  spec.description   = %q{Get all instances in an AutoScaling group by AutoScaling group name.}
  spec.homepage      = 'https://github.com/maximbaibakov/capistrano3-aws-asg-deploy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'aws-sdk-ec2', '~> 1'
  spec.add_dependency 'aws-sdk-autoscaling', '~> 1'
  spec.add_dependency 'capistrano', '> 3.0.0'
  spec.add_dependency 'activesupport', '>= 4.0.0'
  spec.add_dependency 'capistrano-bundler', '~> 2'
end
