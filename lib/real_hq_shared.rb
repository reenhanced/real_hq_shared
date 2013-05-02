# Load configuration.rb first so that Configs object is available to other mixins
required_files = ["configuration"]

required_files += %w(
	git_version
	mailer
  number_handler
	shared_helper
)

required_files.each { |file| require File.dirname(__FILE__) + '/real_hq_shared/' + file }

ActionView::Base.send       :include, ActionView::Helpers::RealHqShared

ActiveRecord::Base.send     :include, RealHqShared::Mailer
ActionController::Base.send :include, RealHqShared::Mailer