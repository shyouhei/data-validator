require 'test-unit'
require 'data/validator'

class Test001Basic < Test::Unit::TestCase

  def test_test
    v = Data::Validator.new(
      'foo' => Numeric
    )
    assert { v.is_a? Data::Validator }

    args = v.validate({ 'foo' => 42 })
    assert { args == { 'foo' => 42 } }

    args = v.validate({ 'foo' => 3.14 })
    assert { args == { 'foo' => 3.14 } }

    args = v.validate( 'foo' => 3.14 )
    assert { args == { 'foo' => 3.14 } }

    # note 'failing cases';

    assert_raise_message(/foo/) { v.validate() }
    assert_raise_message(/foo/) { v.validate({'foo' => 'bar'}) }
    assert_raise_message(/baz|qux/) {
      v.validate({'foo' => 0, 'baz' => 42, qux => 100 })
    }
  end
end
