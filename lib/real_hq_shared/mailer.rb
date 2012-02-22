module RealHqShared
  
  module Mailer
    
    extend ActiveSupport::Concern
    
    module ClassMethods

      def safely_deliver mailer, email, *args, &block   
        # usage:
        # safely_deliver(FooMailer, :email_name, arg1, arg2) do
        #   flash[:error] = "Barf! There was an email error."
        # end
        begin
          mailer.send(email,*args).deliver
        rescue Exception => ex
          # Yields to the block (if provided) if an exception occurs. 
          # This allows us to set an error flash message or take some 
          # other action in case of an ActionMailer exception.
          if Rails.env.production? || Rails.env.staging?
            if respond_to? "notify_airbrake"
              notify_airbrake(ex) rescue nil
            else
              Airbrake.notify(ex) rescue nil
            end
            yield if block_given?
            false
          else
            raise ex
          end
        end
      end
          
    end
    
    def safely_deliver mailer, email, *args, &block   
      self.class.safely_deliver mailer, email, *args, &block
    end  

  end
  
end