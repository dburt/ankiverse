#!/usr/bin/ruby -w

require 'rubygems'
require 'yaml'

require 'bundler'
Bundler.load
require 'nokogiri'
require 'sinatra'

require_relative 'lib/anki_card_generator'
require_relative 'lib/esv_api_request'
require_relative 'lib/sentence_splitter'

class AnkiVerse < Sinatra::Base

  SUGGESTED_PASSAGES = (<<-END).split(/\n/).map {|line| line.strip }
    Genesis 1
    Genesis 12
    Exodus 14
    Exodus 20
    Deuteronomy 6
    2 Samuel 7
    Psalm 1
    Psalm 23
    Psalm 96
    Psalm 100
    Psalm 121
    Isaiah 6
    Isaiah 40
    Isaiah 53
    Obadiah
    Malachi 4
    Matthew 5
    Matthew 6
    Mark 1
    Mark 15
    Luke 2
    Luke 24
    John 1
    John 20
    Romans 1
    Romans 3
    Romans 8
    1 Corinthians 13
    1 Corinthians 15
    Philippians 2
    Jude
    Revelation 1
    Revelation 21
    Revelation 22
  END

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
      body = Net::HTTP.get(URI.parse("https://www.biblegateway.com/passage/?version=NIV&search=" + params[:passage].gsub(/\s+/, '+')))
      doc = Nokogiri(body.gsub(/\<br[^>]*?\>/, "\n"))
      passage = doc.css('.passage-text')
      passage.search('h1').remove
      passage.search('h3').remove
      passage.search('sup').remove unless params[:verse_numbers] == 'with_verse_numbers'
      passage.search('.chapternum').remove
      passage.search('.footnotes').remove
      passage.search('.crossrefs').remove
      passage.search('.publisher-info-bottom').remove
      ref = "#{params[:passage]} (NIV)"
      text = "#{ref}\n#{passage.text}\n#{ref}"

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
