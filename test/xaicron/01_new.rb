require 'test-unit'
require 'data/validator'

class Test01New < Test::Unit::TestCase
  test 'no args' do
    assert_raise ArgumentError do
      Data::Validator.new
    end
  end

  test 'simple' do
    rule = Data::Validator::Recursive.new(
      'foo' => String
    )

    assert { rule.is_a? Data::Validator }
  end

  test 'nested' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => {
        isa:  Integer,
        rule: {
          'baz' => String,
        }
      },
    )

    assert { rule.is_a? Data::Validator }
  end

  # test 'nested (hash)' # is perl specific

  test 'invalid nested rule' do
    assert_raise TypeError do
      Data::Validator::Recursive.new(
        'foo' => String,
        'bar' => {
          isa:  Integer,
          rule: 'invalid'
        },
      )
    end
  end
end
