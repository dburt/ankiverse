require 'net/http'

class EsvApiRequest

  attr_reader :action, :options

  BASE_URI = "https://api.esv.org/v3/passage/text/"

  def initialize(action, options)
    @action = action
    @options = options
    @options['key'] = ENV['ESV_API_KEY'] or raise "ENV var missing: ESV_API_KEY"
    [*@options.delete(:dont_include)].each do |opt|
      @options["include-#{opt}"] = false
    end
  end

  def options_for_query_string
    options.map do |key, val|
      "#{URI.encode_www_form_component key.to_s}=#{URI.encode_www_form_component val.to_s}"
    end.join("&")
  end

  def url
    URI("#{BASE_URI}/#{action}?#{options_for_query_string}")
  end

  def response
    @response ||= Net::HTTP.get(url)
  end

  def self.execute(action, options)
    new(action, options).response
  end
end
