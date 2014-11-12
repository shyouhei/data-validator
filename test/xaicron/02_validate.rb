require 'test-unit'
require 'data/validator'

class Test02Validate < Test::Unit::TestCase

  setup do
    @rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, optional: 1 },
      'baz' => {
        isa: Hash,
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
      'baz' => {
        'hoge' => 'xxx',
        'fuga' => 123,
      },
    }
    params = @rule.validate(input)

    assert { params == input }
  end

  test 'invalid data' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => {
        'fuga' => 'piyo'
      },
    }
    assert_raise_message(/hoge|fuga/) { @rule.validate(input) }
  end

  test 'conflicts' do
    input = {
      'foo' => 'xxx',
      'bar' => 123,
      'baz' => {
        'hoge' => 'yyy',
        'fuga' => 456,
        'piyo' => %w/a b c/,
      },
    }
    assert_raise_message(/hoge|piyo/) { @rule.validate(input) }
  end

  test 'with default option' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Hash,
        rule: {
          'hoge' => String,
          'fuga' => Integer,
        },
      },
    )

    input = {
      'foo' => 'xxx',
      'baz' => {
        'hoge' => 'xxx',
        'fuga' => 123,
      },
    }

    params = rule.validate(input)

    assert { params['bar'] == 1 }
  end

  test 'default option with nested' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Hash,
        rule: {
          'hoge' => { isa: String, default: 'yyy' },
          'fuga' => Integer,
        },
      },
    )

    input = {
      'foo' => 'xxx',
      'baz' => {
        'fuga' => 123,
      },
    }

    params   = rule.validate(input)
    expected = {
      'foo' => 'xxx',
      'bar' => 1,
      'baz' => {
        'hoge' => 'yyy',
        'fuga' => 123,
      },
    }
    assert { params == expected }
  end

  test 'with AllowExtra' do
    rule = Data::Validator::Recursive.new(
      'foo' => String,
      'bar' => { isa: Integer, default: 1 },
      'baz' => {
        isa: Hash,
        with: 'AllowExtra',
        rule: {
          'hoge' => { isa: String, default: 'yyy' },
          'fuga' => Integer
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

    params   = rule.validate(input)
    expected = {
      'foo' => 'xxx',
      'bar' => 1,
      'baz' => {
        'hoge' => 'yyy',
        'fuga' => 123,
        'extra_param_in_baz' => 1,
      },
      'extra_param' => 1,
    }

    assert { params == expected }
  end
end
