module Resque

  class Worker
    alias_method :original_unregister_worker, :unregister_worker
    
    def work(interval = 5.0, &block)
      interval = Float(interval)
      $0 = "resque: Starting"
      startup

      loop do
        wait_for_scale if scaling?
        break if shutdown?

        if not paused? and job = reserve
          log "got: #{job.inspect}"
          job.worker = self
          run_hook :before_fork, job
          working_on job

          if @child = fork
            srand # Reseeding
            procline "Forked #{@child} at #{Time.now.to_i}"
            Process.wait(@child)
          else
            procline "Processing #{job.queue} since #{Time.now.to_i}"
            perform(job, &block)
            exit! unless @cant_fork
          end

          done_working
          @child = nil
        else
          break if interval.zero?
          log! "Sleeping for #{interval} seconds"
          procline paused? ? "Paused" : "Waiting for #{@queues.join(',')}"
          sleep interval
        end
      end

    ensure
      unregister_worker
    end

    def wait_for_scale
      Resque.redis.set("scale:#{self}", true)
      sleep 1 while scaling? and not shutdown?
      Resque.redis.del("scale:#{self}")
    end

    def unregister_worker
      Resque.redis.del("scale:#{self}")
      original_unregister_worker
    end

    def scaling?
      Resque.redis.exists(:scale)
    end

    def self.scaling
      names = all
      return [] unless names.any?

      names.map! { |name| "scale:#{name}" }

      reportedly_scaling = {}

      begin
        reportedly_scaling = redis.mapped_mget(*names).reject do |key, value|
          value.nil? || value.empty?
        end
      rescue Redis::Distributed::CannotDistribute
        names.each do |name|
          value = redis.get name
          reportedly_scaling[name] = value unless value.nil? || value.empty?
        end
      end

      reportedly_scaling.keys.map do |key|
        find key.sub("scale:", '')
      end.compact
    end
  end

end