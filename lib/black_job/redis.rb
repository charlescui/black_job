module BlackJob
  def self.redis
    if defined? @@redis
      return @@redis
    elsif defined? $redis
      return @@redis = $redis
    else
      return @@redis = Redis.new(BlackJob::Config.redis)
    end
  end
end
