module Spec
  struct ContainAllExpectation(T)
    def initialize(@expected_value : T)
    end

    def match(actual_value)
      @expected_value == @expected_value & actual_value
    end

    def failure_message(actual_value)
      "Expected:   #{actual_value.inspect}\nto contain all of: #{@expected_value.inspect}"
    end
  end

  module Expectations
    def contain_all(expected)
      Spec::ContainAllExpectation.new expected
    end
  end
end

