require 'faraday'
require 'json'

class EsvPassageFetcher
  BASE_URL = 'https://api.esv.org/v3/passage/text/'.freeze

  DEFAULT_OPTIONS = {
    'include-passage-references': false,
    'include-verse-numbers': false,
    'include-first-verse-numbers': false,
    'include-footnotes': false,
    'include-headings': false,
    'include-short-copyright': false,
    'indent-paragraphs': 0,
    'indent-poetry': false,
    'indent-declares': 0,
    'indent-psalm-doxology': 0,
  }

  def initialize(ref, verse_numbers: nil, api_token: ENV['ESV_API_KEY'], extra_options: {})
    @ref = ref
    @verse_numbers = verse_numbers
    @api_token = api_token
    @options = DEFAULT_OPTIONS.merge extra_options
    @options[:'include-verse-numbers'] = @verse_numbers if @verse_numbers
  end

  def fetch
    raise ArgumentError, 'missing API token' unless @api_token
    response = Faraday.get(BASE_URL, @options.merge(q: @ref), { 'Authorization' => "Token #{@api_token}" })
    p response
    @json = response.body
    puts @json
  end

  def clean
    json_response = JSON.parse(@json)

    if json_response.key?('passages')
      passage = json_response['passages'].join("\n").strip
      @text = "#{@ref} (ESV)\n#{passage}\n#{@ref} (ESV)"
    else
      raise "Failed to fetch passage: #{json_response['error']}"
    end
  end

  def text
    @text
  end

  def self.fetch(ref, verse_numbers: nil, api_token: ENV['ESV_API_KEY'])
    fetcher = new(ref, verse_numbers:, api_token:)
    fetcher.fetch
    fetcher.clean
    fetcher.text
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts 'Usage: ruby esv_passage_fetcher.rb REF'
  else
    puts EsvPassageFetcher.fetch(ARGV[0], verse_numbers: true)
  end
end
