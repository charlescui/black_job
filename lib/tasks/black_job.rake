namespace :black_job do

  def get_solution_class(str)
    raise ArgumetnError if str.blank?
    str.split(',').map { |s| s.constantize }
  end

  desc "WorkWork...Call a BlackJob::Worker with redis key Key=redis_key and Action=start|stop|restart, some Solutions=[solutions,with,comma] needed if Action is start or restart."
  task :controller => :environment do |t|
    solutions = get_solution_class(ENV["Solutions"])
    worker = BlackJob::Worker.new(ENV["Key"], solutions)
    # 后台模式
    worker.daemonize(ENV["Action"])
    # 前台模式
#    worker.working
  end
end
