require 'minitest/autorun'
require_relative '../lib/bible_gateway_passage_fetcher'

# Integration tests that verify BibleGateway API is working
# These tests make real HTTP requests and can fail if the API is down
class BibleGatewayPassageFetcherIntegrationTest < Minitest::Test
  def test_fetch_psalm_117_niv
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleGatewayPassageFetcher.fetch('Psalm 117')

    refute_nil text, "Expected text to be returned from BibleGateway API"
    refute_empty text, "Expected non-empty text from BibleGateway API"

    # Verify it contains the passage reference
    assert_includes text, "Psalm 117", "Expected text to include passage reference"

    # Verify it contains key words from Psalm 117
    assert_includes text.downcase, "praise", "Expected Psalm 117 to contain 'praise'"
    assert_includes text.downcase, "nations", "Expected Psalm 117 to contain 'nations'"
    assert_includes text.downcase, "lord", "Expected Psalm 117 to contain 'Lord'"
  end

  def test_fetch_john_3_16_niv
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleGatewayPassageFetcher.fetch('John 3:16')

    refute_nil text, "Expected text to be returned from BibleGateway API"
    refute_empty text, "Expected non-empty text from BibleGateway API"

    # Verify it contains the passage reference
    assert_includes text, "John 3:16", "Expected text to include passage reference"

    # Verify it contains key words from John 3:16
    assert_includes text.downcase, "god", "Expected John 3:16 to contain 'God'"
    assert_includes text.downcase, "world", "Expected John 3:16 to contain 'world'"
    assert_includes text.downcase, "son", "Expected John 3:16 to contain 'son'"
  end

  def test_fetch_with_verse_numbers
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    text = BibleGatewayPassageFetcher.fetch('Psalm 23:1-2', verse_numbers: 'with_verse_numbers')

    refute_nil text, "Expected text to be returned from BibleGateway API"
    refute_empty text, "Expected non-empty text from BibleGateway API"

    # Verify it contains verse numbers (as digits followed by non-breaking space)
    assert_match /[1-2]/, text, "Expected text to include verse numbers"
  end

  def test_api_availability
    skip "Set INTEGRATION_TESTS=true to run live API tests" unless ENV['INTEGRATION_TESTS']

    # Test that we can reach the BibleGateway API
    fetcher = BibleGatewayPassageFetcher.new('Genesis 1:1')

    assert_nothing_raised do
      fetcher.fetch
    end

    refute_nil fetcher.text, "Expected API to return some response"
  end
end
