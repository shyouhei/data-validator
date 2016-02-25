require 'test-unit'
require 'data/validator'

class Test01OrClass < Test::Unit::TestCase

  setup do
    @rule = Data::Validator.new(
      'foo' => { isa: [TrueClass, FalseClass] },
    )
  end

  test 'valid data' do
    input = {
      'foo' => false
    }
    params = @rule.validate(input)

    assert { params == input }
  end

  test 'invalid data' do
    input = {
      'foo' => 'false'
    }
    assert_raise_message(/foo/) { @rule.validate(input) }
  end
end
