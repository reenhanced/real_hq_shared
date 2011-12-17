require 'real_hq_shared/configuration.rb' # Load configuration.rb first so that Configs object is available to other mixins
require 'real_hq_shared/campfire.rb'
require 'real_hq_shared/git_version.rb'
require 'real_hq_shared/mailer.rb'
require 'real_hq_shared/shared_helper.rb'
require 'real_hq_shared/try_chain.rb'
require 'real_hq_shared/worker_methods.rb'

ActionView::Base.send       :include, ActionView::Helpers::RealHqShared
            
ActiveRecord::Base.send     :include, RealHqShared::Mailer
ActionController::Base.send :include, RealHqShared::Mailer
