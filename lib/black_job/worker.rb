module BlackJob

  class Worker < Daemon::Base
    attr_accessor :latest_job,:pid_fn

    def initialize(key, solutions)
      @key = key
      @solutions = solutions
      @latest_job,@counter = nil,0
      @running_flag = true
      path = File.join(Rails.root,'tmp','pids','black_job')
      FileUtils.mkdir_p path unless File.exists?(path)
      @pid_fn = File.join(path, "#{key}.pid")
      catch_signal
    end

    def catch_signal
      Signal.trap("INT", proc {stop!})
    end

    def start
      working
    end

    def stop
      stop! && exit
    end

    def stop!
      Rails.logger.error "BlackJob::Worker Terminating: #{$$}"
      @running_flag = false
      exit unless @latest_job
    end

    def working
      while(@running_flag) do
        Rails.logger.info("waiting #{@key}")
        job = BlackJob.redis.blpop(@key,0)
        @latest_job = job
        @solutions.each do |solution|
          if solution.superclass == Solution
            begin
              ret = solution.new(:job => job).solve
              raise SolutionError,"BlackJob working error while solution[#{solution}] solve this job and return #{ret}. redis key:#{@key}" unless ret
              @latest_job = nil, @counter += 1
              Rails.logger.info("BlackJob working success with redis key:#{@key} solution:#{solution}.")
            rescue SolutionError => ex
              Rails.logger.error("BlackJob SolutionError : #{ex.to_s}\n Extra info:\n #{ex.backtrace}")
              BlackJob.redis.lpush(@key,job)
            rescue => ex
              Rails.logger.error("BlackJob working error with redis key:#{@key} solution:#{solution}. Unkown howto solve this exception -- #{ex}, and drop this job -- #{job}\n Extra info:\n #{ex.backtrace}.")
            end
          end
        end
        @latest_job = nil
      end
    end
  end
end
