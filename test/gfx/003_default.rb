require 'test-unit'
require 'data/validator'

class Test003Default < Test::Unit::TestCase

  def test_test
    v = Data::Validator.new(
      'foo' => { isa: Numeric, default: 99 },
    )
    assert { v.is_a? Data::Validator }

    args = v.validate({ 'foo' => 42 })
    assert { args == { 'foo' => 42 } }

    args = v.validate({})
    assert { args == { 'foo' => 99 } }

    args = v.validate()
    assert { args == { 'foo' => 99 } }

    v = Data::Validator.new(
      'foo' => { isa: Numeric, default: 99 },
      'bar' => { isa: Numeric, default: lambda {|validator, rule, args|
         args['foo'] + 1
       } },
    )
    
    args = v.validate()
    assert { args == { 'foo' => 99, 'bar' => 100 } }

    args = v.validate('foo' => 42)
    assert { args == { 'foo' => 42, 'bar' => 43 } }
  end
end
