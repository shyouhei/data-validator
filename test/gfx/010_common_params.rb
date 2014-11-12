require 'test-unit'
require 'data/validator'

class Test010CommonParams < Test::Unit::TestCase

  def test_test
    base_param = {
      'member_id' => { isa: Integer },
      'type'      => { isa: Integer, default: 0, optional: true },
    }

    foo = Data::Validator.new(base_param)
    bar = Data::Validator.new(base_param)

    assert_nothing_raised { foo.validate('member_id' => 10) }
    assert_nothing_raised { bar.validate('member_id' => 10) }
  end
end
