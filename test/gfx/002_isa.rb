require 'test-unit'
require 'data/validator'

class Test002Isa < Test::Unit::TestCase

  def test_test
    v = Data::Validator.new(
      'foo' => { isa: Numeric },
    )
    assert { v.is_a? Data::Validator }

    args = v.validate({ 'foo' => 42 })
    assert { args == { 'foo' => 42 } }

    args = v.validate({ 'foo' => 3.14 })
    assert { args == { 'foo' => 3.14 } }

    # note 'failing cases';

    assert_raise_message(/foo/) { v.validate() }
    assert_raise_message(/foo/) { v.validate({'foo' => 'bar'}) }
  end
end
