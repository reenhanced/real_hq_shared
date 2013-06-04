require 'test_helper'
require 'real_hq_shared/number_handler'
require 'active_model'

class NumberHandlerTest < ActiveSupport::TestCase
  def setup
    @number_handled = Class.new do
      include ActiveModel::AttributeMethods # For self[:attribute] support
      include RealHqShared::NumberHandler

      attr_accessor :office_phone, :home_phone, :price, :price_dollars, :price_cents

      def []=(attribute, value)
        instance_variable_set("@#{attribute}", value)
      end

      def attributes
        # Hash keys here must be strings.
        # This method must be implemented when ActiveModel::AttributeMethods is included
        # http://api.rubyonrails.org/classes/ActiveModel/AttributeMethods.html
        @attributes ||= {
          'office_phone'  => office_phone,
          'home_phone'    => home_phone,
          'price'         => price,
          'price_dollars' => price_dollars,
          'price_cents'   => price_cents
        }
      end
    end
  end

  ## .sanitize_phone_number

  test ".sanitize_phone_number returns empty string for invalid number" do
    assert_nil @number_handled.sanitize_phone_number("reenhanced")
  end

  test ".sanitize_phone_number strips non_digits" do
    expected_number = "18662376836"
    dirty_string    = "Call us at 1.866.237.6836"

    assert_equal(@number_handled.sanitize_phone_number(dirty_string), expected_number)
  end

  test ".sanitize_phone_number prepends 1 if it is not present" do
    expected_number = "18662376836"
    short_number    = "8662376836"

    assert_equal(@number_handled.sanitize_phone_number(short_number), expected_number)
  end

  ## .sanitize_number_string

  test ".sanitize_number_string returns Number objects unmodified" do
    number = 51
    assert_kind_of(Fixnum, 51)

    assert_same(@number_handled.sanitize_number_string(number), number)
  end

  test ".sanitize_number_string returns the first number in a space separated list of numbers" do
    expected      = "1"
    number_string = "1 2 3"

    assert_equal(@number_handled.sanitize_number_string(number_string), expected)
  end

  test ".sanitize_number_string returns the first number in a dash separated list of numbers" do
    expected      = "1"
    number_string = "1-2-3"

    assert_equal(@number_handled.sanitize_number_string(number_string), expected)
  end

  test ".sanitize_number_string returns the first number in string like x to y" do
    expected      = "1"
    number_string = "1 to 1000"

    assert_equal(@number_handled.sanitize_number_string(number_string), expected)
  end

  test ".sanitize_number_string returns nil is the string doesn't contain numbers" do
    number_string = "Expert ruby coders love writing great code"

    assert_nil(@number_handled.sanitize_number_string(number_string))
  end

  ## .phone_numbers

  test ".phone_numbers automatically sanitizes phone numbers" do
    @number_handled.phone_numbers :office_phone, :home_phone

    phone_number = "866.237.6836"
    sanitized_phone_number = @number_handled.sanitize_phone_number(phone_number)

    number_handled_object = @number_handled.new

    number_handled_object.office_phone = phone_number
    number_handled_object.home_phone   = phone_number

    assert_equal(number_handled_object.office_phone, sanitized_phone_number)
    assert_equal(number_handled_object.home_phone,   sanitized_phone_number)
  end

  ## .currency_numbers

  test ".currency_numbers sanitizes the number string for the attribute" do
    @number_handled.currency_numbers [:price, :cents]

    number_string = "100 to 500"
    sanitized_number_string = @number_handled.sanitize_number_string(number_string)

    number_handled_object = @number_handled.new
    number_handled_object.price = number_string

    assert_equal(number_handled_object.price, sanitized_number_string)
  end
end
