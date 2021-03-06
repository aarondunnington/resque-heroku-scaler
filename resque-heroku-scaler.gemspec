$LOAD_PATH.unshift 'lib'
require 'resque/plugins/heroku_scaler/version'

Gem::Specification.new do |s|
  s.name              = "resque-heroku-scaler"
  s.version           = Resque::Plugins::HerokuScaler::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Resque plugin to autoscale Heroku workers"
  s.homepage          = "http://github.com/spiro/resque-heroku-scaler"
  s.email             = "spirogh@gmail.com"
  s.authors           = ["Aaron Dunnington"]

  s.files             = %w( README.md Rakefile LICENSE HISTORY.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.add_dependency "resque", "~> 1.20.0"
  s.add_dependency "heroku", "~> 2.28.7"

  s.description = <<description
    This gem provides autoscaling for Resque workers on Heroku.
description
end