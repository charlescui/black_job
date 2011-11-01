require 'fileutils'

module BlackJob
  module Daemon
#    WorkingDirectory = File.expand_path(File.dirname(__FILE__))  
    WorkingDirectory = Rails.root

    class Base
      def pid_fn
        File.join(WorkingDirectory, "#{name}.pid")
      end
      
      def daemonize(action='start')
        Controller.daemonize(self,action)
      end
    end
    
    module PidFile
      def self.store(daemon, pid)
        File.open(daemon.pid_fn, 'w+') {|f| f << pid}
      end
      
      def self.recall(daemon)
        IO.read(daemon.pid_fn).to_i rescue nil
      end
    end
    
    module Controller
      def self.daemonize(daemon,action)
        case action
        when 'start'
          start(daemon)
        when 'stop'
          stop(daemon)
        when 'restart'
          stop(daemon)
          start(daemon)
        else
          puts "Invalid command. Please specify start, stop or restart."
          exit
        end
      end
      
      def self.start(daemon)
        fork do
          Process.setsid
          exit if fork
          PidFile.store(daemon, Process.pid)
          Dir.chdir WorkingDirectory
          File.umask 0000
          STDIN.reopen "/dev/null"
          STDOUT.reopen "/dev/null", "a"
          STDERR.reopen STDOUT
          FileHandler.reconnect
          trap("TERM") {daemon.stop; exit}
          daemon.start
        end
      end
    
      def self.stop(daemon)
        if !File.file?(daemon.pid_fn)
          puts "Pid file not found. Is the daemon started?"
          exit
        end
        pid = PidFile.recall(daemon)
        FileUtils.rm(daemon.pid_fn)
        pid && Process.kill("TERM", pid)
      end
    end

    # 当以daemon模式启动时
    # Rails和服务端链接的socket在父进程退出的时候
    # 被远端中断，导致子进程拿到的文件句柄已经失效
    # 所以这些父进程的连接要在子进程启动时重建
    module FileHandler
      def self.reconnect
        rails_db_reconnect
      end

      def self.rails_db_reconnect
        ActiveRecord::Base.establish_connection Rails.configuration.database_configuration[Rails.env]
      end
    end
  end
end
