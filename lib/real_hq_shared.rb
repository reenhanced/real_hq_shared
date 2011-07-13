Dir[File.expand_path(File.dirname(__FILE__) + '/real_hq_shared/*.rb')].each { |file| require file }

ApplicationHelper.send(:include, SharedHelper)