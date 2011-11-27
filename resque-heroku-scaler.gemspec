$LOAD_PATH.unshift 'lib'
require 'resque/plugins/resque_heroku_scaler/version'

Gem::Specification.new do |s|
  s.name              = "resque-heroku-scaler"
  s.version           = Resque::Plugins::ResqueHerokuScaler::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Resque plugin to autoscale Heroku workers"
  s.homepage          = "http://github.com/spiro/resque-heroku-scaler"
  s.email             = "spirogh@gmail.com"
  s.authors           = ["Aaron Dunnington"]

  s.files             = %w( README.md Rakefile LICENSE HISTORY.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.add_dependency "resque", "~> 1.19.0"
  s.add_dependency "heroku", "~> 2.14.0"

  s.description = <<description
    This gem provides autoscaling behavior for Resque jobs on Heroku.
description
end