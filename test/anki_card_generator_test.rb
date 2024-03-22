require 'minitest/autorun'
require_relative '../lib/anki_card_generator'

class AnkiCardGeneratorTest < Minitest::Test
  def setup
    @poem = "This is a test poem.\nIt has multiple lines.\nLine 3\nLine 4\nLine 5"
    @other_fields = ["extra", "tags"]
    @generator = AnkiCardGenerator.new(@poem, @other_fields)
  end

  def test_lines
    expected_result = [
      "This is a test poem.",
      "It has multiple lines.",
      "Line 3",
      "Line 4",
      "Line 5",
    ]
    assert_equal expected_result, @generator.lines
  end

  def test_csv_with_default_options
    expected_result = "\xEF\xBB\xBFThis is a test poem.<br/>...,It has multiple lines.,extra,tags\nThis is a test poem.<br/>It has multiple lines.<br/>...,Line 3,extra,tags\nIt has multiple lines.<br/>Line 3<br/>...,Line 4,extra,tags\nLine 3<br/>Line 4<br/>...,Line 5,extra,tags\n"
    assert_equal expected_result, @generator.csv(lines: [2, 1])
  end

  def test_csv_with_no_ellipsis
    options = { lines: [2, 1], ellipsis: false }
    expected_result = "\xEF\xBB\xBFThis is a test poem.<br/>,It has multiple lines.,extra,tags\nThis is a test poem.<br/>It has multiple lines.<br/>,Line 3,extra,tags\nIt has multiple lines.<br/>Line 3<br/>,Line 4,extra,tags\nLine 3<br/>Line 4<br/>,Line 5,extra,tags\n"
    assert_equal expected_result, @generator.csv(options)
  end

  def test_csv_with_invalid_options
    options = { lines: [0, 3] }
    assert_raises(ArgumentError) { @generator.csv(options) }
  end
end