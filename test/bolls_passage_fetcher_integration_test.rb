require 'minitest/autorun'
require_relative '../lib/bolls_passage_fetcher'

# Integration tests that verify bolls.life API is working
# These tests make real HTTP requests and can fail if the API is down
class BollsPassageFetcherIntegrationTest < Minitest::Test
  def test_fetch_psalm_117_kjv
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BollsPassageFetcher.fetch('Psalm 117:1-2', translation: 'kjv')

    refute_nil text, "Expected text to be returned from bolls.life"
    refute_empty text, "Expected non-empty text from bolls.life"

    # Verify it contains the passage reference
    assert_includes text, "Psalm", "Expected text to include book name"

    # Verify it contains key words from Psalm 117 (KJV version)
    assert_includes text.downcase, "praise", "Expected Psalm 117 to contain 'praise'"
    assert_includes text.downcase, "nations", "Expected Psalm 117 to contain 'nations'"
  end

  def test_fetch_john_3_16_kjv
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BollsPassageFetcher.fetch('John 3:16', translation: 'kjv')

    refute_nil text, "Expected text to be returned from bolls.life"
    refute_empty text, "Expected non-empty text from bolls.life"

    # Verify it contains the passage reference
    assert_includes text.downcase, "john", "Expected text to include book name"

    # Verify it contains key words from John 3:16
    assert_includes text.downcase, "god", "Expected John 3:16 to contain 'God'"
    assert_includes text.downcase, "world", "Expected John 3:16 to contain 'world'"
    assert_includes text.downcase, "son", "Expected John 3:16 to contain 'son'"
  end

  def test_fetch_with_verse_numbers
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BollsPassageFetcher.fetch('Psalm 23:1-2', translation: 'kjv', verse_numbers: true)

    refute_nil text, "Expected text to be returned from bolls.life"
    refute_empty text, "Expected non-empty text from bolls.life"

    # Verify it contains verse numbers
    assert_match /[1-2]/, text, "Expected text to include verse numbers"
  end

  def test_fetch_genesis_1_1
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BollsPassageFetcher.fetch('Genesis 1:1', translation: 'kjv')

    refute_nil text, "Expected text to be returned from bolls.life"
    refute_empty text, "Expected non-empty text from bolls.life"

    # Verify it contains key words from Genesis 1:1
    assert_includes text.downcase, "beginning", "Expected Genesis 1:1 to contain 'beginning'"
    assert_includes text.downcase, "god", "Expected Genesis 1:1 to contain 'God'"
    assert_includes text.downcase, "created", "Expected Genesis 1:1 to contain 'created'"
  end

  def test_api_availability
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    # Test that we can reach the bolls.life API
    fetcher = BollsPassageFetcher.new('Genesis 1:1')

    fetcher.fetch
    fetcher.clean
    refute_nil fetcher.text, "Expected API to return some response"
  end

  def test_passage_parsing
    # Unit test for passage parsing (doesn't require API call)
    fetcher = BollsPassageFetcher.new('John 3:16')
    book_name, chapter, verses = fetcher.send(:parse_passage, 'John 3:16')

    assert_equal 'John', book_name
    assert_equal 3, chapter
    assert_equal '16', verses
  end

  def test_passage_parsing_with_range
    # Unit test for passage parsing with verse range
    fetcher = BollsPassageFetcher.new('Psalm 23:1-6')
    book_name, chapter, verses = fetcher.send(:parse_passage, 'Psalm 23:1-6')

    assert_equal 'Psalm', book_name
    assert_equal 23, chapter
    assert_equal '1-6', verses
  end

  def test_book_id_lookup
    assert_equal 43, BollsPassageFetcher::BOOK_IDS['john']
    assert_equal 19, BollsPassageFetcher::BOOK_IDS['psalm']
    assert_equal 1, BollsPassageFetcher::BOOK_IDS['genesis']
    assert_equal 66, BollsPassageFetcher::BOOK_IDS['revelation']
  end
end
