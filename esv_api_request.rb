require 'net/http'

class EsvApiRequest

  attr_reader :action, :options

  BASE_URI = "http://www.esvapi.org/v2/rest"

  def initialize(action, options)
    @action = action
    @options = options
    @options['key'] = 'TEST'
    [*@options.delete(:dont_include)].each do |opt|
      @options["include-#{opt}"] = false
    end
  end

  def options_for_query_string
    options.map do |key, val|
      "#{URI.escape key.to_s}=#{URI.escape val.to_s}"
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
