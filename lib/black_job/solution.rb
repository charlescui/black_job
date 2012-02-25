# 解决方案模板
module BlackJob
  class Solution
    def initialize(opts={})
      
    end

    # solve函数要求保证操作的完整性
    # 如果一个Job没有工作完成，务必返回false并回滚
    # 反之如果Job完成成功，则需要返回true
    def solve
      
    end
  end
end

Dir[File.join(File.dirname(__FILE__), "solutions", "*.rb")].each { |f| 
  require f
}