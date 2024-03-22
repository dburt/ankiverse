require 'minitest/autorun'
require_relative '../lib/sentence_splitter'

class SentenceSplitterTest < Minitest::Test
  def test_lines_of_with_short_sentences
    sentence = "This is a test sentence. It has multiple lines. Each line has a certain number of words."
    splitter = SentenceSplitter.new(sentence)
    expected_result = [
      "This is a test sentence.",
      "It has multiple lines.",
      "Each line has a certain number of words."
    ]
    assert_equal expected_result, splitter.lines_of(5..10)
  end

  def test_lines_of_with_conjunctions
    sentence = "This is a test sentence and it has multiple lines. Each line has a certain number of words."
    splitter = SentenceSplitter.new(sentence)
    expected_result = [
      "This is a test sentence",
      "and it has multiple lines.",
      "Each line has a certain number of words."
    ]
    assert_equal expected_result, splitter.lines_of(5..10)
  end

  def test_lines_of_with_comma
    sentence = "This is a test sentence, it has more than one line. Each line has a certain number of words."
    splitter = SentenceSplitter.new(sentence)
    expected_result = [
      "This is a test sentence,",
      "it has more than one line.",
      "Each line has a certain number of words."
    ]
    assert_equal expected_result, splitter.lines_of(5..10)
  end

  def test_lines_of_with_invalid_range
    sentence = "This is a test sentence. It has multiple lines. Each line has a certain number of words."
    splitter = SentenceSplitter.new(sentence)
    assert_raises(ArgumentError) { splitter.lines_of(5..9) }
  end
end