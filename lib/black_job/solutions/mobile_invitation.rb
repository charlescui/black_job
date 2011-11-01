module BlackJob
  class MobileInvitation < Solution
    def initialize(opts={})
      @key = opts[:job][0]
      raise MobileNeededError,"mobile is nil!!" unless opts[:job]
      @mobile = opts[:job][1]
    end

    def get_user
      if UserInfo.find_by_mobile(@mobile).blank?
        passwd = Utils.rand_passwd
        @user = User.new(:name => @mobile, :email => "#{@mobile}@yiqikan.tv", :password => passwd, :password_confirmation => passwd)
        if @user.save_without_session_maintenance
          UserInfo.create(:user_id => @user.id, :mobile => @mobile)
        end
        notify_unregister_user
      else
        @user = UserInfo.find_by_mobile(@mobile).user
        notify_register_user
      end
    end

    def solve
      begin
        get_user
        return true
      rescue Exception => e
        return false
      end
    end

    def notify_unregister_user
      Rails.logger.info("notify to unregister user#{@user.inspect}")
    end

    def notify_register_user
      Rails.logger.info("notify to register user#{@user.inspect}")
    end
  end
end
