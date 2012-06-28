module Resque
  module Plugins
    module HerokuScaler
      module Config
        extend self

        attr_writer :scale_manager
        attr_writer :scale_interval
        attr_writer :poll_interval
        attr_writer :scale_timeout
        attr_reader :scale_with

        def scale_manager
          @scale_manager || :heroku
        end

        def scale_interval
          @scale_interval || 5
        end

        def poll_interval
          @poll_interval || 1
        end

        def scale_timeout
          @scale_timeout || 90
        end

        def scale_for(pending)
          return @scale_with.call(pending) if @scale_with
          default_scale_with(pending)
        end

        def scale_with=(block)
          @scale_with = block
        end

        def default_scale_with(pending)
          return 0 if pending <= 0

          [{
              :workers => 1,
              :jobs => 1
            },
            {
              :workers => 2,
              :jobs => 15
            },
            {
              :workers => 3,
              :jobs => 25
            },
            {
              :workers => 4,
              :jobs => 40
            },
            {
              :workers => 5,
              :jobs => 60
            }
          ].reverse_each do |required_scale|
            if pending >= required_scale[:jobs]
              return required_scale[:workers]
            end
          end
          return 0
        end
      end
    end
  end
end