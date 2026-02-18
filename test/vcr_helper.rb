require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('fixtures/vcr_cassettes', __dir__)
  config.hook_into :webmock

  if ENV['ESV_API_KEY']
    config.filter_sensitive_data('<ESV_API_KEY>') { ENV['ESV_API_KEY'] }
  end

  config.default_cassette_options = {
    record: ENV['INTEGRATION_TESTS'] ? :new_episodes : :none,
    match_requests_on: [:method, :uri]
  }
end

module VCRTestHelper
  def use_cassette(name, &block)
    cassette_path = File.join(VCR.configuration.cassette_library_dir, "#{name}.yml")

    unless ENV['INTEGRATION_TESTS'] || File.exist?(cassette_path)
      skip "Cassette not found. Set INTEGRATION_TESTS=true to record."
    end

    VCR.use_cassette(name, &block)
  end
end
