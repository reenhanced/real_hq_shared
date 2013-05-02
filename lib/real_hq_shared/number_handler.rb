module RealHqShared

  module NumberHandler

    extend ActiveSupport::Concern

    included do

      if self < ActiveRecord::Base

        extend CommonMethods
        extend ActiveRecordClassMethods

      elsif self < ActionController::Base

        include CommonMethods

      end

    end

    module CommonMethods

      def sanitize_phone_number number
        number = (number || "").to_s
        number.gsub!(/\D/,'') if number
        number = "1" + number if number.present? && number.index("1") != 0 && number.size == 10

        return number.present? ? number : nil
      end

      def sanitize_number_string number
        return number unless number.is_a?(String)

        number = number.to_s.split(" ").first || ""
        number = number.to_s.split("-").first || ""
        number = number.split("to").first || ""
        number.gsub!(/[^0-9|.][.]?/,'')

        return number
      end

    end # CommonMethods

    module ActiveRecordClassMethods

      def phone_numbers(*attrs)
        unless attrs.empty?
          attrs.each do |att|
            setter_method = ("#{att.to_s}=").to_sym
            send :define_method, setter_method do |number|
              self[att.to_sym] = self.class.sanitize_phone_number(number)
            end
          end
        end
      end # phone_numbers

      def currency_numbers(*attrs)
        unless attrs.empty?
          attrs.each do |att|

            att, units = *att
            att = att.to_s

            setter_method = "#{att}=".to_sym
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
                (send(att) || 0) / 100.0
              end

              send :define_method, dollar_setter_method do |val|
                send(setter_method, val.to_f * 100)
              end

            end
          end
        end
      end # currency_numbers

    end # ActiveRecordClassMethods

  end

end