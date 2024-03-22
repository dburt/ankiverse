#!/usr/bin/ruby -w

require 'rubygems'
require 'yaml'

require 'bundler'
Bundler.load
require 'sinatra'

require_relative 'lib/anki_card_generator'
require_relative 'lib/bible_gateway_passage_fetcher'
require_relative 'lib/esv_api_request'
require_relative 'lib/sentence_splitter'

class AnkiVerse < Sinatra::Base

  SUGGESTED_PASSAGES = File.read('suggested_passages.txt').lines.map(&:strip)

  get '/' do
    @passage = SUGGESTED_PASSAGES[rand(SUGGESTED_PASSAGES.size)]
    erb :index
  end

  post '/' do
    next params.to_yaml if params["debug"]

    response['Content-Type'] = "text/csv; charset=utf-8"
    response['Content-Disposition'] = "attachment; filename=ankiverse.csv"

    AnkiCardGenerator.new(params["poem"], params["other_fields"]).
      csv(:lines => params["lines"].map(&:to_i),
          :ellipsis => !!params["ellipsis"])
  end

  get '/bible/:passage/:version/:verse_numbers?' do
    case params[:version]
    when 'NIV'
      text = BibleGatewayPassageFetcher.fetch(params[:passage], :verse_numbers => params[:verse_numbers])

    when 'ESV'

      options = {
        :key => "IP",
        :output_format => "plain-text",
        :line_length => 0,
        :dont_include => %w(
          passage-references
          first-verse-numbers
          footnotes
          footnote-links
          headings
          subheadings
          audio-link
          short-copyright
          passage-horizontal-lines
          heading-horizontal-lines
        )
      }

      options[:dont_include] << 'verse_numbers' unless params[:verse_numbers] == 'with_verse_numbers'


      response = EsvApiRequest.execute(:passageQuery,
        options.merge(:passage => params[:passage]))

      # Add whitespace to verse numbers if necessary for more readability
      response.gsub!("\]", "\] ") if params[:verse_numbers] == 'with_verse_numbers'

      text = "#{params[:passage]}\n#{response}"
    else
      raise ArgumentError, "Please select a valid version"
    end

    @passage = params[:passage]
    @poem = SentenceSplitter.new(text).lines_of(5..12).join("\n")
    @other_fields = [@passage]
    erb :index
  end

end
