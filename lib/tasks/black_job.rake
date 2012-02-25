namespace :black_job do

  def get_solution_class(str)
    raise ArgumetnError if str.blank?
    str.constantize
  end

  desc "WorkWork...Call a BlackJob::Worker with redis and Action=start|stop|restart, some Solution=solution needed if Action is start or restart.Daemon=true|false."
  task :controller => :environment do |t|
    puts "*"*50
    puts "Welcome to BlackJob"
    puts "*"*50
    solution = get_solution_class(ENV["Solution"])
    worker = BlackJob::Worker.new(solution)
    puts "BlackJob doing..."
    if ENV["Daemon"] == "true"
      # 后台模式
      worker.daemonize(ENV["Action"] || "start")
    else
      # 前台模式
      worker.working
    end
  end
end
