module Resque
  
  class Worker

    def work(interval = 5.0, &block)
      interval = Float(interval)
      $0 = "resque: Starting"
      startup

      loop do
        break if shutdown?
        
        if should_lock?
          lock
          break
        end

        pause if should_pause?

        if job = reserve(interval)
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
          log! "Timed out after #{interval} seconds"
          procline paused? ? "Paused" : "Waiting for #{@queues.join(',')}"
        end
      end

    ensure
      unregister_worker
      wait_for_shutdown if locked?
    end

    def should_lock?
      redis.exists(:lock)
    end

    def lock
      redis.sadd(:locked, self)
      @locked = true
    end

    def locked?
      @locked
    end

    def should_unlock?
      return false if should_lock?
      locked?
    end

    def wait_for_shutdown
      sleep 0.1 until shutdown? or should_unlock?
    end

    def self.locked
      Array(redis.smembers(:locked))
    end

    def self.lock
      redis.set(:lock, true)
    end

    def self.unlock
      redis.del(:lock)
      redis.del(:locked)
    end

    def self.prune
      all_workers = Worker.all
      all_workers.each do |worker|
        worker.unregister_worker
      end
    end

  end
end
