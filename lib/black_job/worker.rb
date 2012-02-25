module BlackJob

  class Worker < Daemon::Base
    attr_accessor :latest_job,:pid_fn

    def initialize(solution)
      @key = solution.to_s
      @solution = solution
      @latest_job,@counter = nil,0
      @running_flag = true
      path = File.join(Rails.root,'tmp','pids','black_job')
      FileUtils.mkdir_p path unless File.exists?(path)
      @pid_fn = File.join(path, "#{@key}.pid")
      catch_signal
    end

    def catch_signal
      Signal.trap("INT", proc {self.clean_pid_file if self.is_daemon;stop})
    end

    def start
      working
    end

    def stop
      BlackJob::Logger.logger.error "BlackJob::Worker Terminating: #{$$}"
      @running_flag = false
      exit unless @latest_job
    end
    
    def clear_key!
      if (BlackJob.redis.exists(@key) && BlackJob.redis.type(@key) != "list")
        BlackJob::Logger.logger.error("Current redis key(#{@key}) exists : #{BlackJob.redis.exists(@key)}, type : #{BlackJob.redis.type(@key)}.The key will be reset to empty list.")
        BlackJob.redis.del(@key)
      end
    end

    def working
      puts "BlackJob working now. - #{BlackJob.redis.inspect}"
      while(@running_flag) do
        BlackJob::Logger.logger.info("waiting #{@key}")
        self.clear_key!
        job = BlackJob.redis.blpop(@key,0)
        BlackJob::Logger.logger.info("Get a job - #{job}")
        BlackJob::Logger.logger.info("Solve a #{@solution} job cost time - #{Benchmark.measure {self.solve_job(job)}}")
      end
      BlackJob::Logger.logger.info("BlackJob is stopping now.The job is retain in redis[#{@key}]")
    end
    
    def solve_job(job)
      @latest_job = job
      if @solution.superclass == Solution
        BlackJob::Logger.logger.info("Start solute the job with solution - #{@solution}.")
        begin
          ret = @solution.new(:job => job).solve
          raise SolutionError,"BlackJob working error while solution[#{@solution}] solve this job and return #{ret}. redis key:#{@key}" unless ret
          @latest_job = nil, @counter += 1
          BlackJob::Logger.logger.info("BlackJob working success with redis key:#{@key} solution:#{@solution}.")
        rescue SolutionError => ex
          BlackJob::Logger.logger.error("BlackJob SolutionError.")
          #BlackJob.redis.lpush(@key,job)
        rescue => ex
          BlackJob::Logger.logger.error("BlackJob working error with redis key:#{@key} solution:#{@solution}. Unkown howto solve this exception -- #{ex}, and drop this job -- #{job}\n Extra info:\n #{ex.backtrace.join("\n")}.")
        end
      end
      @latest_job = nil
    end
    
  end
  
end
