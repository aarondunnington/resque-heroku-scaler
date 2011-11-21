require 'rush'

module Resque
  module Plugins
    module ResqueHerokuScaler
      module Manager

        class Local

          def initialize(options={})
            @path = options[:path] || ENV['RUSH_PATH']
            @processes = []
          end

          def workers
            @processes.length
          end

          def workers=(qty)
            active = workers
            return if qty == active
            if qty > active
              scale_up(qty-active)
              return
            end
            scale_down(active-qty)
          end

          def scale_up(qty)
            qty.times do
              process = Rush::Box.new[@path].bash('rake resque:work', :background => true, :env => { :BUNDLE_GEMFILE => '' })
              @processes.push(process) if process
            end
          end

          def scale_down(qty)
            i = 0
            until i == qty or @processes.empty?
              process = @processes.pop
              kill(process)
              i += 1
            end
          end

          def kill(process)
            process.children.each do |child|
              kill(child)
            end
            process.kill
          end
        end

      end
    end
  end
end