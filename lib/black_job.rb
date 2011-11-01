require 'rails'
require File.join(File.dirname(__FILE__),'black_job','engine')
require File.join(File.dirname(__FILE__),'black_job','redis')
require File.join(File.dirname(__FILE__),'black_job','solution')
require File.join(File.dirname(__FILE__),'black_job','worker')
require File.join(File.dirname(__FILE__),'black_job','exceptions')
require File.join(File.dirname(__FILE__),'black_job','daemon')
require File.join(File.dirname(__FILE__),'black_job','config')

module BlackJob
end

