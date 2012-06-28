require 'resque'
require 'resque/plugins/heroku_scaler/version'
require 'resque/plugins/heroku_scaler/config'
require 'resque/plugins/heroku_scaler/manager'
require 'resque/plugins/heroku_scaler/worker'
require 'resque/plugins/heroku_scaler/resque'

module Resque
  module Plugins

    module HerokuScaler
      class << self

        def run
          startup
          loop do
            begin
              scale
            rescue Exception => e
              log "Scale failed with #{e.class.name} #{e.message}"
            end
            wait_for_scale
          end
        end

        def scale
          required = scale_for(pending)
          active = workers

          return if required == active

          if required > active
            log "Scale workers from #{active} to #{required}"
            scale_workers(required)
            return
          end
                      
          return if pending?

          scale_down(active)
        end

        def wait_for_scale
          sleep Resque::Plugins::HerokuScaler::Config.scale_interval
        end

        def scale_for(pending)
          Resque::Plugins::HerokuScaler::Config.scale_for(pending)
        end

        def scale_workers(qty)
          Resque::Plugins::HerokuScaler::Manager.workers = qty
        end

        def scale_down(active)
          log "Scale #{active} workers down"

          lock

          timeout = Time.now + Resque::Plugins::HerokuScaler::Config.scale_timeout
          until locked == active or Time.now >= timeout
            sleep Resque::Plugins::HerokuScaler::Config.poll_interval
          end

          scale_workers(0)

          timeout = Time.now + Resque::Plugins::HerokuScaler::Config.scale_timeout
          until Time.now >= timeout
            if offline?
              log "#{active} workers scaled down successfully"
              prune
              break
            end
            sleep Resque::Plugins::HerokuScaler::Config.poll_interval
          end

        ensure
          unlock
        end

        def workers
          Resque::Plugins::HerokuScaler::Manager.workers
        end
        
        def offline?
          workers.zero?
        end

        def pending?
          pending > 0
        end

        def pending
          Resque.info[:pending]
        end

        def lock
          Resque.lock
        end

        def unlock
          Resque.unlock
        end
        
        def locked
          Resque.info[:locked]
        end
        
        def prune
          Resque.prune
        end

        def configure
          yield Resque::Plugins::HerokuScaler::Config
        end

        def startup
          STDOUT.sync = true
          trap('TERM') do
            log "Shutting down scaler"
            exit
          end
          log "Starting scaler"
          unlock
        end

        def log(message)
          puts "*** #{message}"
        end
      end

    end
  end
end