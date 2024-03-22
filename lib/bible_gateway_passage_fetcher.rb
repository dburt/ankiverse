require 'net/http'
require 'nokogiri'

class BibleGatewayPassageFetcher
  def initialize(ref, verse_numbers: nil, version: 'NIV')
    @ref = ref
    @verse_numbers = verse_numbers
    @version = version
  end

  def fetch
    @html = Net::HTTP.get(URI.parse("https://www.biblegateway.com/passage/?version=#{@version}&search=" + @ref.gsub(/\s+/, '+')))
  end

  def clean
    doc = Nokogiri(@html.gsub(/\<br[^>]*?\>/, "\n"))
    passage = doc.css('.passage-text')
    passage.search('h1').remove
    passage.search('h3').remove
    passage.search('sup').remove unless @verse_numbers == 'with_verse_numbers'
    passage.search('sup.crossreference').remove
    passage.search('sup.footnote').remove
    passage.search('.chapternum').remove
    passage.search('.footnotes').remove
    passage.search('.crossrefs').remove
    passage.search('.publisher-info-bottom').remove
    ref = "#{@ref} (NIV)"
    text = passage.text.strip.gsub(/(\w)\.(\w)/, '\1. \2')
    @text = "#{ref}\n#{text}\n#{ref}"
  end

  def text
    @text
  end

  def self.fetch(ref, verse_numbers: nil, version: 'NIV')
    fetcher = new(ref, verse_numbers: verse_numbers, version: version)
    fetcher.fetch
    fetcher.clean
    fetcher.text
  end
end
