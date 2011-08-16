# Load configuration.rb first so that Configs object is available to other mixins
require 'real_hq_shared/configuration.rb' 

require 'real_hq_shared/campfire.rb'                                        
require 'real_hq_shared/git_version.rb'
require 'real_hq_shared/shared_helper.rb'                                        
require 'real_hq_shared/try_chain.rb'                                        

class ActionView::Base
  include ActionView::Helpers::RealHqShared
end