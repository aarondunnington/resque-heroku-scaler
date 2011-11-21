namespace :resque do
  namespace :scaler do  
    task :setup

    desc "Start Resque Heroku Scaler process"
    task :run => :setup do
      require 'resque/plugins/resque-heroku-scaler'
      Resque::Plugins::ResqueHerokuScaler.run
    end
  end
end