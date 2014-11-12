require 'test-unit'
require 'data/validator'

class Test004Xor < Test::Unit::TestCase

  def test_test
    v = Data::Validator.new(
      'uri'        => { xor: %w(schema host path_query) },

      'schema'     => { default: 'http' },
      'host'       => { default: '127.0.0.1' },
      'path_query' => { default: '/' },

      'method'     => { default: 'GET' },
    )

    # note 'success cases';

    args = v.validate({ 'uri' => 'https://example.com/' })
    assert { args == { 'uri' => 'https://example.com/', 'method' => 'GET' } }

    args = v.validate({
      'schema'     => 'https',
      'host'       => 'example.com',
      'path_query' => '/index.html',
    })
    assert_equal args, {
      'schema'     => 'https',
      'host'       => 'example.com',
      'path_query' => '/index.html',
      'method'     => 'GET',
    }

    args = v.validate({
      'host' => 'example.com',
    })
    assert_equal args, {
      'schema'     => 'http',
      'host'       => 'example.com',
      'path_query' => '/',
      'method'     => 'GET',
    }

    args = v.validate();
    assert_equal args, {
      'schema'     => 'http',
      'host'       => '127.0.0.1',
      'path_query' => '/',
      'method'     => 'GET',
    }

    # note 'failure cases';

    assert_raise_message(/uri versus.+schema/) {
      v.validate({ 'uri' => 'foo', 'schema' => 'http' })
    }

    assert_raise_message(/uri versus.+(host|schema)/) {
      v.validate({ 'uri' => 'foo', 'schema' => 'http', 'host' => 'example.com' })
    }

    # note 'case without defaults';

    v = Data::Validator.new(
      'uri'        => { xor: %w(schema host path_query) },

      'schema'     => { default: 'http' },
      'host'       => { },
      'path_query' => { default: '/' },

      'method'     => { default: 'GET' },
    )

    args = v.validate(
      'uri' => 'http://example.com/',
    )
    assert_equal args, {
      'uri'        => 'http://example.com/',
      'method'     => 'GET',
    }

    args = v.validate(
      'host' => 'example.com',
    )
    assert_equal args, {
      'schema'     => 'http',
      'host'       => 'example.com',
      'path_query' => '/',
      'method'     => 'GET',
    }

    assert_raise_message(/(uri|host)/) {
      v.validate()
    }
  end
end
