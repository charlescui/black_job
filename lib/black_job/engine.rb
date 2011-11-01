module BlackJob
  class Engine < Rails::Engine

    engine_name :black_job
    # Load rake tasks
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "..", "tasks", "*.rake")].each { |task| 
        load task
      }
    end
  end
end
