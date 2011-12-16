module RealHqShared

  module ResqueWorkerMethods
    
    def self.included worker
      worker.extend(WorkerClassMethods)
    end
    
    module WorkerClassMethods 
      
      def set_log log_name
        log_filepath    = File.join(Rails.root, 'log', "#{log_name}.log")
        @log_file       = File.open(log_filepath, "a") 
      end                            

      def log_file
        return @log_file if @log_file.present?

        raise "Log file not instantiated."
      end

      def update_log message
        message = "[#{Time.now.to_s}] #{message}" 
        puts message
        log_file.puts message
      end             

      def log_exception exception
        update_log "[EXCEPTION] #{exception}\r\n\r\n" + (0..9).map { |i| "     " + exception.backtrace[i] }.join("\r\n")
      end

      def close_log
        log_file.close
      end
      
      def handle_exception ex
        notify_airbrake(ex) rescue nil
        log_exception ex
      end
      
      def set_status_to_processing! objects                         
        objects = Array(objects)
        
        ids_by_table_name = objects.inject({}) do |hash,o| 
          hash[o.class.table_name] ||= []
          hash[o.class.table_name] << o.id
          hash
        end
        
        ids_by_table_name.each do |table_name, ids|
          query = "UPDATE #{table_name} SET status = 'processing' WHERE id IN (#{ids.join(",")});"
          ActiveRecord::Base.connection.execute(query)                                            
        end
      end
      
      
    end
      
  end

end