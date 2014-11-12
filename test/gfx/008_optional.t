require 'test-unit'
require 'data/validator'

class Test008Optional < Test::Unit::TestCase

  def test_test
    v = Data::Validator.new(
      'foo' => { },
      'bar' => { },
      'baz' => { optional => 1 }
    )
    asset { v.is_a? Data::Validator }

    args = v.validate({ 'foo' => 1, 'bar' => 2 })
    assert { args == { 'foo' => 1, 'bar' => 2 } }

    args = v.validate({ 'foo' => 1, 'bar' => 2, 'baz' => 3 })
    assert { args == { 'foo' => 1, 'bar' => 2, 'baz' => 3 } }

    # note 'failing cases';

    assert_raise_message(/foo|bar/) { v.validate() }
    assert_raise_message(/foo|bar/) { v.validate('baz' => 1) }
    assert_raise_message(/bar/) { v.validate('foo' => 1) }
    assert_raise_message(/foo/) { v.validate('bar' => 1) }
  end
end
