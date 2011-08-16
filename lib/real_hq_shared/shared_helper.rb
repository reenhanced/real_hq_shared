module ActionView

  module Helpers

    module RealHqShared
       
      ### Javascript helpers          
      def js_from_google library, version
        javascript_tag do 
          %Q(google.load('#{library}', '#{version}');)
        end
      end          
  
      def js_for_google_conversion label, options={}
        options[:id]        ||= Configs[:google_conversion_id]
        options[:language]  ||= "en"
        options[:format]    ||= "3"
        options[:color]     ||= "ffffff"
        options[:value]     ||= 0
    
        javascript_tag do
          %Q(
          var google_conversion_id       = #{options[:id]};
          var google_conversion_language = \"#{options[:language]}\";
          var google_conversion_format   = \"#{options[:format]}\";
          var google_conversion_color    = \"#{options[:color]}\";
          var google_conversion_label    = \"#{label}\";
          var google_conversion_value    = #{options[:value]};
          ).html_safe
        end + 
        javascript_include_tag(Configs[:google_conversion_js_file]) +
        content_tag(:noscript) do
          content_tag(:div, :style => "display:inline;") do
            image_tag "http://www.googleadservices.com/pagead/conversion/#{options[:id]}/?label=#{label}&guid=ON&script=0", :height=>"1", :width=>"1", :style=>"border-style:none;", :alt=>""
          end
        end
      end                   
  
      def js_for_typekit 
        javascript_include_tag(Configs[:typekit_js_file]) + 
        javascript_tag("try{Typekit.load();}catch(e){}")
      end   
  
      def js_for_wufoo_form form_name, options={}
        form_name    = form_name.camelcase(:lower)  
        form_options = {:user_name => "realhq", :form_hash => "#{form_name}", :auto_resize => false, :ssl => "true"}.merge(options)
        json_options = form_options.inject({}){|o,(k,v)| o[k.to_s.camelcase(:lower)] = v; o}.to_json
       
        javascript_tag do                                                                                                                                                                                                      
          "var host = ((\"https:\" == document.location.protocol) ? \"https://secure.\" : \"http://\");document.write(unescape(\"%3Cscript src='\" + host + \"wufoo.com/scripts/embed/form.js' type='text/javascript'%3E%3C/script%3E\"));".html_safe
        end +
        javascript_tag do                                                                                                                                                                                                      
          "var #{form_name} = new WufooForm();
          #{form_name}.initialize(#{json_options});
          #{form_name}.display();".html_safe
        end
      end
          
    end
    
  end
  
end