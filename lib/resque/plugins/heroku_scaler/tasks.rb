require 'resque/tasks'

namespace :resque do
  desc "Start Resque Heroku Scaler process"
  task :heroku_scaler => :setup do
    require 'resque-heroku-scaler'
    Resque::Plugins::HerokuScaler.run
  end
end