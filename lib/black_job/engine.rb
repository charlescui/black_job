module BlackJob
  class Engine < Rails::Engine
    # 初始化redis配置
    BlackJob::Config.redis = {"host"=>"127.0.0.1", "port" => "6379"}

    engine_name :black_job
    # Load rake tasks
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "..", "tasks", "*.rake")].each { |task| 
        load task
      }
    end
  end
end
