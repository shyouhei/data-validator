require 'test-unit'
require 'data/validator'

class Test02Validate < Test::Unit::TestCase
  test 'requires with AllowExtra' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Hash,
        with: 'AllowExtra',
        rule: {
          'hoge' => { isa: String }, # requires
          'fuga' => Integer,
        },
      },
    ).with('AllowExtra')

    input = {
      'foo' => 'xxx',
      'baz' => {
        'fuga' => 123,
        'extra_param_in_baz' => 1,
      },
      'extra_param' => 1,
    }

    assert_raise_message(/missing/) { rule.validate(input) }
  end
end
