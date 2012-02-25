module BlackJob
  class Logger
	  def self.logger
      @logger ||= ::Logger.new("black_job.log")
	  end
  end
end
