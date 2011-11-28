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

          log "Scale workers from #{active} to #{required}"

          if required > active
            scale_workers(required)
            return
          end

          signal_workers
          stop = timeout
          wait_for_workers until ready_to_scale(active) or timeout?(stop)
          scale_workers(required)

        ensure
          resume_workers
        end

        def wait_for_scale
          sleep Resque::Plugins::HerokuScaler::Config.scale_interval
        end

        def wait_for_workers
          sleep Resque::Plugins::HerokuScaler::Config.poll_interval
        end

        def scale_for(pending)
          Resque::Plugins::HerokuScaler::Config.scale_for(pending)
        end

        def scale_workers(qty)
          Resque::Plugins::HerokuScaler::Manager.workers = qty
        end

        def workers
          Resque::Plugins::HerokuScaler::Manager.workers
        end

        def signal_workers
          Resque.redis.set(:scale, true)
        end

        def resume_workers
          Resque.redis.del(:scale)
        end

        def timeout?(stop)
          Time.now >= stop
        end

        def timeout
          Time.now + Resque::Plugins::HerokuScaler::Config.scale_timeout
        end

        def pending
          Resque.info[:pending].to_i
        end

        def ready_to_scale(active)
          Resque.info[:scaling] == active
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
          resume_workers
        end

        def log(message)
          puts "*** #{message}"
        end
      end

    end
  end
end