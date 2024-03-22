require 'minitest/autorun'
require_relative '../lib/esv_passage_fetcher'

class EsvPassageFetcherTest < Minitest::Test
  def json_fixture
    @json ||= File.read('test/fixtures/esv_api_response.json')
  end

  def json_fixture_minus_verse_numbers
    json_fixture.gsub(/\[\d+\] /, '')
  end

  def test_clean
    fetcher = EsvPassageFetcher.new('Ps117')
    fetcher.instance_variable_set(:@json, json_fixture_minus_verse_numbers)
    fetcher.clean
    expected_text = "Ps117 (ESV)\nPraise the LORD, all nations!\nExtol him, all peoples!\nFor great is his steadfast love toward us,\nand the faithfulness of the LORD endures forever.\nPraise the LORD!\nPs117 (ESV)"
    assert_equal expected_text, fetcher.text
  end

  def test_clean_with_verse_numbers
    fetcher = EsvPassageFetcher.new('Ps117', verse_numbers: true)
    fetcher.instance_variable_set(:@json, json_fixture)
    fetcher.clean
    expected_text = "Ps117 (ESV)\n[1] Praise the LORD, all nations!\nExtol him, all peoples!\n[2] For great is his steadfast love toward us,\nand the faithfulness of the LORD endures forever.\nPraise the LORD!\nPs117 (ESV)"
    assert_equal expected_text, fetcher.text
  end
end