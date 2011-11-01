module BlackJob
  def self.redis  
    @@redis ||= Redis.new({"host"=>"127.0.0.1", "port" => "6379"})
  end
end
