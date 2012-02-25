# -*- coding: utf-8 -*-

=begin
例子:
使用是在Rails的controller中放入参数
后台会立刻得到这个任务去执行
可以同时开启多个后台,当一个worker忙不过来的时候,其它空闲的worker会得到这个任务

def upload
  $redis.lpush("BlackJob::UploadContacts", {
      :contacts => params[:contacts],
      :u_id => current_user.id
    }.to_json
  )
  render :nothing => true
end

=end

module BlackJob
  class UploadContacts < Solution
    def initialize(opts={})
      @key = opts[:job][0]
      raise MobileNeededError,"mobile is nil!!" unless opts[:job][1]
      jopts = JSON.parse(opts[:job][1])
			
      @contacts = JSON.parse(jopts["contacts"])
      @current_user = User.find(jopts["u_id"]) if jopts["u_id"]
    end

    def solve
      begin
        BlackJob::Logger.logger.info("Receive Contacts in BlackJob - contacts count : #{@contacts.size}")
        data = Contact.unpack(@contacts)
        Contact.insert(@current_user, data)
        return true
      rescue Exception => ex
        BlackJob::Logger.logger.error("BlackJob UploadContacts solve with error -- #{ex.to_s} \n #{ex.backtrace.join("\n")}.")
        return false
      end
    end

  end
end
