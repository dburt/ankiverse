require 'minitest/autorun'
require 'dotenv/load'
require_relative '../lib/esv_passage_fetcher'

# Integration tests that verify ESV API is working
# These tests make real HTTP requests and can fail if the API is down or if the API key is missing
class EsvPassageFetcherIntegrationTest < Minitest::Test
  def test_api_key_present
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    refute_nil ENV['ESV_API_KEY'], "Expected ESV_API_KEY to be set in environment"
    refute_empty ENV['ESV_API_KEY'], "Expected ESV_API_KEY to be non-empty"
  end

  def test_fetch_psalm_117
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']
    skip "ESV_API_KEY not set" unless ENV['ESV_API_KEY']

    text = EsvPassageFetcher.fetch('Psalm 117')

    refute_nil text, "Expected text to be returned from ESV API"
    refute_empty text, "Expected non-empty text from ESV API"

    # Verify it contains the passage reference
    assert_includes text, "Psalm 117", "Expected text to include passage reference"

    # Verify it contains key words from Psalm 117 (ESV version)
    assert_includes text.downcase, "praise", "Expected Psalm 117 to contain 'praise'"
    assert_includes text.downcase, "nations", "Expected Psalm 117 to contain 'nations'"
    assert_includes text.downcase, "lord", "Expected Psalm 117 to contain 'LORD'"
  end

  def test_fetch_john_3_16
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']
    skip "ESV_API_KEY not set" unless ENV['ESV_API_KEY']

    text = EsvPassageFetcher.fetch('John 3:16')

    refute_nil text, "Expected text to be returned from ESV API"
    refute_empty text, "Expected non-empty text from ESV API"

    # Verify it contains the passage reference
    assert_includes text, "John 3:16", "Expected text to include passage reference"

    # Verify it contains key words from John 3:16
    assert_includes text.downcase, "god", "Expected John 3:16 to contain 'God'"
    assert_includes text.downcase, "world", "Expected John 3:16 to contain 'world'"
    assert_includes text.downcase, "son", "Expected John 3:16 to contain 'son'"
  end

  def test_fetch_with_verse_numbers
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']
    skip "ESV_API_KEY not set" unless ENV['ESV_API_KEY']

    text = EsvPassageFetcher.fetch('Psalm 23:1-2', verse_numbers: true)

    refute_nil text, "Expected text to be returned from ESV API"
    refute_empty text, "Expected non-empty text from ESV API"

    # ESV API includes verse numbers in [1] format
    assert_includes text, "[1]", "Expected text to include verse number [1]"
  end

  def test_api_availability
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']
    skip "ESV_API_KEY not set" unless ENV['ESV_API_KEY']

    # Test that we can reach the ESV API
    fetcher = EsvPassageFetcher.new('Genesis 1:1')

    assert_nothing_raised do
      fetcher.fetch
    end

    refute_nil fetcher.text, "Expected API to return some response"
  end

  def test_handles_missing_api_key_gracefully
    # Temporarily remove API key to test error handling
    original_key = ENV['ESV_API_KEY']
    ENV['ESV_API_KEY'] = nil

    fetcher = EsvPassageFetcher.new('Psalm 117')

    # The API should handle this gracefully (either by raising an appropriate error
    # or returning a helpful message)
    assert_raises(StandardError) do
      fetcher.fetch
    end

  ensure
    ENV['ESV_API_KEY'] = original_key
  end
end
