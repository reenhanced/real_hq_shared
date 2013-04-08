require 'ostruct'

# From https://www.ruby-forum.com/topic/137104
class NestedOstruct
  def self.new(hash)
    OpenStruct.new(hash.inject({}){|r,p| r[p[0]] = p[1].kind_of?(Hash) ?  NestedOstruct.new(p[1]) : p[1]; r })
  end

  def [](key)
  	self.send(key)
  end
end

class OpenStruct
  def [](key)
    self.send(key)
  end
end
                                                                   
config_file = Rails.root.join('config', 'config.yml')                

if File.exists?(config_file)
  configs_hash = HashWithIndifferentAccess.new(YAML.load_file(config_file))
  Configs = NestedOstruct.new(configs_hash)
else
  puts "Configs object not created because config/config.yml does not exist. Create this file if you would like to use Configs." 
end


# To access configs, given the following configs hash:
# { :foo => { :bar => { :baz => "hello!" } } }

# Configs[:foo][:bar][:baz]
# Configs.foo.bar.baz
# Configs[:foo].bar.baz
# Configs.foo[:bar].baz

# etc...