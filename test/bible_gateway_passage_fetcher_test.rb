require 'minitest/autorun'
require_relative '../lib/bible_gateway_passage_fetcher'

class BibleGatewayPassageFetcherTest < Minitest::Test
  def html_fixture
    @html ||= File.read('test/fixtures/bible_gateway_response.html')
  end

  def nbsp_tab
    "\u00a0" * 4
  end

  def test_clean
    fetcher = BibleGatewayPassageFetcher.new('Psalm 117')
    fetcher.instance_variable_set(:@html, html_fixture)
    fetcher.clean
    expected_text = "Psalm 117 (NIV)\nPraise the Lord, all you nations;\n#{nbsp_tab}extol him, all you peoples.\nFor great is his love toward us,\n#{nbsp_tab}and the faithfulness of the Lord endures forever. Praise the Lord.\nPsalm 117 (NIV)"
    assert_equal expected_text, fetcher.text
  end

  def test_clean_with_verse_numbers
    fetcher = BibleGatewayPassageFetcher.new('Psalm 117', verse_numbers: 'with_verse_numbers')
    fetcher.instance_variable_set(:@html, html_fixture)
    fetcher.clean
    expected_text = "Psalm 117 (NIV)\n1\u00a0Praise the Lord, all you nations;\n#{nbsp_tab}extol him, all you peoples.\n2\u00a0For great is his love toward us,\n#{nbsp_tab}and the faithfulness of the Lord endures forever. Praise the Lord.\nPsalm 117 (NIV)"
    assert_equal expected_text, fetcher.text
  end

  # def test_fetch_with_different_version
  #   fetcher = BibleGatewayPassageFetcher.new('Psalm 117', version: 'ESV')
  #   fetcher.instance_variable_set(:@html, html_fixture)
  #   fetcher.clean
  #   expected_text = "Psalm 117 (NIV)\nPraise the Lord, all you nations;\n\textol him, all you peoples.\nFor great is his love toward us,\n    and the faithfulness of the Lord endures forever.Praise the Lord.\nPsalm 117 (NIV)"
  #   assert_equal expected_text, fetcher.text
  # end

end