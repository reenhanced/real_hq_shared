class Object  
  def try_chain(*args_for_try_chain)    
    arg_for_try = args_for_try_chain.shift
    result      = self.try(arg_for_try)
    result.send (args_for_try_chain.size > 1 ? :try_chain : :try), *args_for_try_chain
  end  
end