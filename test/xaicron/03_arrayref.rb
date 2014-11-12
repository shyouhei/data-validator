require 'test-unit'
require 'data/validator'

# There is no such thing like an arrayref in Ruby.  But here I follow the
# original naming anyway.
class Test03Arrayref < Test::Unit::TestCase

  setup do
    @rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, optional: 1 },
      'baz' => {
        isa: Array,
        rule: {
          'hoge' => String,
          'fuga' => Integer,
          'piyo' => {
            isa:      Array,
            xor:      %w/hoge/,
            optional: true,
          },
        },
      },
    )
  end

  test 'valid data' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => [
        {
          'hoge' => 'xxx',
          'fuga' => 123,
        },
      ],
    }
    params = @rule.validate(input)

    assert { params == input }
  end

  test 'invalid data as array' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => {},
    }
    assert_raise_message(/baz/) { @rule.validate(input) }
  end

  test 'invalid data at the first of array' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => [
        {
          'fuga' => 'piyo',
        },
        {
          'hoge' => 'xxx',
          'fuga' => 1,
        },
      ]
    }

    assert_raise_message(/baz:#0/) { @rule.validate(input) }
  end

  test 'invalid data at the second of array' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => [
        {
          'hoge' => 'xxx',
          'fuga' => 1,
        },
        {
          'fuga' => 'piyo',
        },
        {
          'hoge' => 'xxx',
          'fuga' => 2,
        },
        {
          'fuga' => 'piyo',
        },
      ]
    }

    assert_raise_message(/baz:#1:fuga/) { @rule.validate(input) }
  end

  test 'nested array' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Array,
        rule: {
          'piyo' => {
            isa: Array,
            rule: {
              'hoge' => { isa: String, default: 'yyy' },
              'fuga' => Integer,
            }
          },
        },
      },
    )

    input = {
      'foo' => 'xxx',
      'baz' => [
        {
          'piyo' => [
            {
              'fuga' => 123,
            },
          ],
        },
      ],
    };

    params   = rule.validate(input)
    expected = {
      'foo' => 'xxx',
      'bar' => 1,
      'baz' => [
        {
          'piyo' => [
            {
              'hoge' => 'yyy',
              'fuga' => 123,
            },
          ],
        },
      ],
    }

    assert { params == expected }
  end

  test 'conflicts' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => [
        {
          'hoge' => 'xxx',
          'fuga' => 456,
          'piyo' => %w/a b c/,
        },
      ]
    }

    assert_raise_message(/baz:#0:piyo/) { @rule.validate(input) }
  end

  test  'with default option' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Array,
        rule: {
          'hoge' => String,
          'fuga' => Integer,
        },
      },
    )

    input = {
      'foo' => 'xxx',
      'baz' => [
        {
          'hoge' => 'xxx',
          'fuga' => 456,
        },
      ]
    }

    params = rule.validate(input)

    assert { params['bar'] == 1 }
  end

  test 'default option with nested' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Array,
        rule: {
          'hoge' => { isa: String, default: 'yyy' },
          'fuga' => Integer,
        },
      },
    )

    input = {
      'foo' => 'xxx',
      'baz' => [
        {
          'fuga' => 456,
        },
      ]
    }

    params   = rule.validate(input)
    expected = {
      'foo' => 'xxx',
      'bar' => 1,
      'baz' => [
        {
          'hoge' => 'yyy',
          'fuga' => 456,
        },
      ]
    }

    assert { params == expected }
  end

  test 'with AllowExtra' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Array,
        with: 'AllowExtra',
        rule: {
          'hoge' => { isa: String, default: 'yyy' },
          'fuga' => Integer
        },
      },
    ).with('AllowExtra')


    input = {
      'foo' => 'xxx',
      'baz' => [
        {
          'fuga' => 123,
          'extra_param_in_baz' => 1,
        },
      ],
      'extra_param' => 1,
    }

    params   = rule.validate(input)
    expected = {
      'foo' => 'xxx',
      'bar' => 1,
      'baz' => [
        {
          'hoge' => 'yyy',
          'fuga' => 123,
          'extra_param_in_baz' => 1,
        },
      ],
      'extra_param' => 1,
    }

    assert { params == expected }
  end
end
