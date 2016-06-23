require 'rubygems'
require 'bundler'
STDERR.puts RUBY_VERSION
Bundler.setup(:default, :fcgi)
require 'rack'

class Rack::PathInfoRewriter
  def initialize(app)
    @app = app
  end

  def call(env)
    env['SCRIPT_NAME'] = ''  # Don't delete it--Rack::URLMap assumes it is not nil
    pathInfo, query = env['REQUEST_URI'].split('?', 2)
    env['PATH_INFO'] = pathInfo
    env['QUERY_STRING'] = query
    @app.call(env)
  end
end

Dir.chdir('..') do
  app, options = Rack::Builder.parse_file('config.ru')
  wrappedApp = Rack::Builder.new do
    use Rack::ShowExceptions
    use Rack::PathInfoRewriter
    run app
  end

  Rack::Handler::FastCGI.run wrappedApp
end
