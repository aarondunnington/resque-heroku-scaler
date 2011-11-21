require 'heroku'

module Resque
  module Plugins
    module ResqueHerokuScaler
      module Manager

        class Heroku
          def initialize(options={})
            @heroku = ::Heroku::Client.new(ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD'])
          end

          def workers
            @heroku.ps(ENV['HEROKU_APP']).count { |p| p["process"] =~ /worker\.\d?/ }
          end

          def workers=(qty)
            @heroku.ps_scale(ENV['HEROKU_APP'], :type => 'worker', :qty => qty)
          end
        end

      end
    end
  end
end