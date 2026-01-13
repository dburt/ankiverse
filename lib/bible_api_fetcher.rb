require 'net/http'
require 'json'
require 'uri'

# Fetches Bible passages from bible-api.com
# Supports multiple translations including WEB (default), KJV, and others
# No API key required
class BibleApiFetcher
  attr_reader :text

  def initialize(passage, options = {})
    @passage = passage
    @translation = options[:translation] || 'web'  # Default to World English Bible
    @verse_numbers = options[:verse_numbers]
    @text = nil
    @json_response = nil
  end

  def self.fetch(passage, options = {})
    fetcher = new(passage, options)
    fetcher.fetch
    fetcher.clean
    fetcher.text
  end

  def fetch
    # bible-api.com expects passages like: John 3:16 or Psalm 117
    # URL format: https://bible-api.com/john 3:16?translation=kjv
    encoded_passage = URI.encode_www_form_component(@passage)
    url = "https://bible-api.com/#{encoded_passage}"
    url += "?translation=#{@translation}" unless @translation == 'web'

    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.code.to_i == 200
      @json_response = JSON.parse(response.body)
    else
      raise "Failed to fetch passage from bible-api.com: #{response.code} - #{response.body}"
    end

    self
  end

  def clean
    return unless @json_response

    verses = @json_response['verses'] || []
    reference = @json_response['reference'] || @passage
    translation_name = @json_response['translation_name'] || @translation.upcase

    # Build the text with prefix
    @text = "#{reference} (#{translation_name})\n"

    # Add each verse
    verses.each do |verse|
      verse_text = verse['text'].strip

      if @verse_numbers && verse['verse']
        @text += "#{verse['verse']} #{verse_text}\n"
      else
        @text += "#{verse_text}\n"
      end
    end

    # Add suffix with reference
    @text += "#{reference} (#{translation_name})"

    self
  end
end

# Allow running this file directly for testing
if __FILE__ == $0
  if ARGV.length == 0
    puts "Usage: ruby bible_api_fetcher.rb 'passage' [translation]"
    puts "Example: ruby bible_api_fetcher.rb 'John 3:16' kjv"
    exit 1
  end

  passage = ARGV[0]
  translation = ARGV[1] || 'web'

  puts BibleApiFetcher.fetch(passage, translation: translation)
end
