require 'minitest/autorun'
require_relative '../lib/bible_api_fetcher'

# Integration tests that verify bible-api.com is working
# These tests make real HTTP requests and can fail if the API is down
class BibleApiFetcherIntegrationTest < Minitest::Test
  def test_fetch_psalm_117_web
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleApiFetcher.fetch('Psalm 117')

    refute_nil text, "Expected text to be returned from bible-api.com"
    refute_empty text, "Expected non-empty text from bible-api.com"

    # Verify it contains the passage reference
    assert_includes text, "Psalm 117", "Expected text to include passage reference"

    # Verify it contains key words from Psalm 117
    assert_includes text.downcase, "praise", "Expected Psalm 117 to contain 'praise'"
    assert_includes text.downcase, "nations", "Expected Psalm 117 to contain 'nations'"
  end

  def test_fetch_john_3_16_kjv
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleApiFetcher.fetch('John 3:16', translation: 'kjv')

    refute_nil text, "Expected text to be returned from bible-api.com"
    refute_empty text, "Expected non-empty text from bible-api.com"

    # Verify it contains the passage reference
    assert_includes text, "John 3:16", "Expected text to include passage reference"

    # Verify it contains key words from John 3:16
    assert_includes text.downcase, "god", "Expected John 3:16 to contain 'God'"
    assert_includes text.downcase, "world", "Expected John 3:16 to contain 'world'"
    assert_includes text.downcase, "son", "Expected John 3:16 to contain 'son'"
  end

  def test_fetch_with_verse_numbers
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleApiFetcher.fetch('Psalm 23:1-2', verse_numbers: true)

    refute_nil text, "Expected text to be returned from bible-api.com"
    refute_empty text, "Expected non-empty text from bible-api.com"

    # Verify it contains verse numbers
    assert_match /[1-2]/, text, "Expected text to include verse numbers"
  end

  def test_fetch_multiple_verses
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleApiFetcher.fetch('Romans 8:28-30')

    refute_nil text, "Expected text to be returned from bible-api.com"
    refute_empty text, "Expected non-empty text from bible-api.com"

    # Verify it contains the passage reference
    assert_includes text, "Romans", "Expected text to include book name"
  end

  def test_api_availability
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    # Test that we can reach the bible-api.com API
    fetcher = BibleApiFetcher.new('Genesis 1:1')

    assert_nothing_raised do
      fetcher.fetch
    end

    refute_nil fetcher.text, "Expected API to return some response"
  end
end
