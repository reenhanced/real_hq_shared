module RealHqShared
  module Mailer

    def safely_deliver mailer, email, *args, &block   
      # usage:
      # safely_deliver(FooMailer, :email_name, arg1, arg2) do
      #   flash[:error] = "Barf! There was an email error."
      # end
      begin                   
        mailer.send(email,*args).deliver
      rescue Exception => ex
        # Yields to the block (if provided) if an exception occurs. 
        # This allows us to set an error flash message or take some other action in case of an ActionMailer exception.
        if Rails.env.production? || Rails.env.staging?
          notify_airbrake(ex) rescue nil
          yield if block_given?
          true
        else
          raise ex
        end
      end
    end  

  end
end