require 'test-unit'
require 'data/validator'

class Test104ExtraArgs < Test::Unit::TestCase

  def test_test
    v = Data::Validator.new(
      'foo' => { },
    ).with('AllowExtra')

    args = v.validate('foo' => 42, 'bar' => 15)
    assert { args == {'foo' => 42, 'bar' => 15} }

    args = v.validate('bar' => 15, 'foo' => 42) # reversed order
    assert { args == {'foo' => 42, 'bar' => 15} }
  end
end
