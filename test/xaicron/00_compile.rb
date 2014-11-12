require 'test-unit'

class Test00Compile < Test::Unit::TestCase
  def test_require
    assert_nothing_raised do
      require 'data/validator'
    end
  end
end
