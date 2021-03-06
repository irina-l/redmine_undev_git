require File.expand_path('../../../test_helper', __FILE__)

class RedmineUndevGit::CustomFieldValueTest < ActiveSupport::TestCase

  def setup
    @cfvalue = CustomFieldValue.new
  end

  def test_value_blank_for_nil
    @cfvalue.value = nil
    assert_equal true, @cfvalue.value_blank?
  end

  def test_value_blank_for_empty_string
    @cfvalue.value = ''
    assert_equal true, @cfvalue.value_blank?
  end

  def test_value_blank_for_empty_array
    @cfvalue.value = []
    assert_equal true, @cfvalue.value_blank?
  end

  def test_value_blank_for_array_with_blank_values
    @cfvalue.value = ['', nil]
    assert_equal true, @cfvalue.value_blank?
  end

  def test_value_blank_for_array_with_nil
    @cfvalue.value = [nil]
    assert_equal true, @cfvalue.value_blank?
  end

  def test_value_blank_for_non_blank_value
    @cfvalue.value = :x
    assert_equal false, @cfvalue.value_blank?
  end

  def test_value_blank_for_array_with_non_blank_value
    @cfvalue.value = ['', nil, :x]
    assert_equal false, @cfvalue.value_blank?
  end

end
