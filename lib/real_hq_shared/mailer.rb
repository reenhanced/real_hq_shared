module RealHqShared
  
  module Mailer
    
    extend ActiveSupport::Concern

    def safely_deliver mailer, email, *args, &block   
      self.class.safely_deliver mailer, email, *args, &block
    end  
    
    module ClassMethods

      def safely_deliver mailer, email, *args, &block   
        # usage:
        # safely_deliver(FooMailer, :email_name, arg1, arg2) do
        #   flash[:error] = "Barf! There was an email error."
        # end
        begin
          mailer.send(email,*args).deliver
        rescue => ex
          # Yields to the block (if provided) if an error occurs. 
          # This allows us to set an error flash message or take some 
          # other action in case of an ActionMailer error.
          if Rails.env.production? || Rails.env.staging?
            if respond_to? "notify_airbrake"
              notify_airbrake(ex) rescue nil
            else
              Airbrake.notify(ex) rescue nil
            end
            yield if block_given?
            false
          else
            # Don't raise exception in development or test if there's 
            # no internet connection. Otherwise, raise the exception. 
            if ex.is_a?(SocketError)
              Rails.logger.error "SocketError - mail not delivered."
            else
              raise ex
            end
          end
        end
      end
          
    end
  
  end
  
end