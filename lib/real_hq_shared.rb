# Load configuration.rb first so that Configs object is available to other mixins
require 'real_hq_shared/configuration.rb' 

require 'real_hq_shared/application_helper.rb'                                        
require 'real_hq_shared/configuration.rb'                                        
require 'real_hq_shared/try_chain.rb'                                        

class ActionView::Base
  include RealHqShared
end