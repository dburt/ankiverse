require 'minitest/autorun'
require_relative '../lib/bible_gateway_passage_fetcher'
require_relative 'vcr_helper'

# Integration tests that verify BibleGateway API is working
# These tests make real HTTP requests and can fail if the API is down
class BibleGatewayPassageFetcherIntegrationTest < Minitest::Test
  include VCRTestHelper

  def test_fetch_psalm_117_niv
    use_cassette('bible_gateway/test_fetch_psalm_117_niv') do
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
  end

  def test_fetch_john_3_16_niv
    use_cassette('bible_gateway/test_fetch_john_3_16_niv') do
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
  end

  def test_fetch_with_verse_numbers
    use_cassette('bible_gateway/test_fetch_with_verse_numbers') do
      text = BibleGatewayPassageFetcher.fetch('Psalm 23:1-2', verse_numbers: 'with_verse_numbers')

      refute_nil text, "Expected text to be returned from BibleGateway API"
      refute_empty text, "Expected non-empty text from BibleGateway API"

      # Verify it contains verse numbers (as digits followed by non-breaking space)
      assert_match /[1-2]/, text, "Expected text to include verse numbers"
    end
  end

  def test_api_availability
    use_cassette('bible_gateway/test_api_availability') do
      # Test that we can reach the BibleGateway API
      fetcher = BibleGatewayPassageFetcher.new('Genesis 1:1')

      fetcher.fetch
      fetcher.clean
      refute_nil fetcher.text, "Expected API to return some response"
    end
  end
end
