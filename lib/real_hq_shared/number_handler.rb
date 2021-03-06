module RealHqShared

  module NumberHandler

    class InvalidAttribute < Exception ; end

    extend ActiveSupport::Concern

    included do

    end

    module ClassMethods

      def sanitize_phone_number number
        number = (number || "").to_s
        number.gsub!(/\D/,'') if number
        number = "1" + number if number.present? && number.index("1") != 0 && number.size == 10

        return number if number.present?
      end

      def sanitize_number_string number
        return number unless number.is_a?(String)

        number = number.split(" ").first || ""
        number = number.split("-").first || ""
        number = number.split("to").first || ""
        number.gsub!(/[^0-9|.][.]?/,'')


        return number if number.present?
      end

      def phone_numbers(*attrs)
        attrs.each do |att|
          send :define_method, setter_method_for_attribute(att) do |number|
            self[att.to_sym] = self.class.sanitize_phone_number(number)
          end
        end
      end # phone_numbers

      def currency_numbers(*attrs)
        attrs.each do |att|

          att, units = *att
          att = att.to_s

          setter_method = setter_method_for_attribute(att)

          send :define_method, setter_method do |string|
            self[att.to_sym] = self.class.sanitize_number_string(string)
          end

          case units.try(:to_sym)
          when :cents
            # (a) if the cents attribute name ends in _cents then the dollar setter method
            # should be the attribute without _cents (i.e. "price_cents" and "price").
            # (b) otherwise, the dollar setter method thould be the attribute with
            # _dollars (i.e. "price" and "price_dollars").
            dollar_method = if att.rindex("_cents") == (att.length - ("_cents").length) # (a)
              att[0, att.rindex("_cents")] # returns "price" from "price_cents"
            else # (b)
              att + "_dollars" # returns "price_dollars" from "price"
            end
            dollar_setter_method = "#{dollar_method}=".to_sym

            send :define_method, dollar_method do
              cents_val = send(att)
              cents_val / 100.0 if cents_val
            end

            send :define_method, dollar_setter_method do |dollar_val|
              dollar_val = self.class.sanitize_number_string(dollar_val)
              send(setter_method, dollar_val.to_f * 100) if dollar_val.present?
            end

          end
        end
      end # currency_numbers

      def dates(*attrs)
        options = attrs.extract_options!

        attrs.each do |att|
          send :define_method, setter_method_for_attribute(att) do |original_date|
            date =  case
                    when [Date,DateTime,Time].include?(original_date.class) || original_date.nil?
                      original_date
                    else
                      original_date.present? ? Time.strptime(original_date, options[:format] || "%m/%d/%Y").utc.to_date : nil
                    end

            self[att.to_sym] = date
          end
        end
      end # dates

      private

      def setter_method_for_attribute(attribute)
        setter_method = ("#{attribute.to_s}=").to_sym

        case
        when self.instance_methods(true).include?(setter_method)
          setter_method
        else
          # raise an exception if there isn't a setter method to override
          raise InvalidAttribute.new("#{attribute} not a valid attribute")
        end
      end

    end # ClassMethods

  end

end
