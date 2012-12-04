#!/usr/bin/ruby -w

require 'rubygems'
require 'sinatra'
require 'fastercsv'
require 'iconv'
require 'yaml'

require './esv_api_request'
require './sentence_splitter'

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

    iconv = Iconv.new('UTF-8', 'WINDOWS-1252')
    lines = params["poem"].to_s.strip.split(/\r?\n/)
    lines.map! do |line|
      iconv.iconv line.strip
    end

    other_fields = params["other_fields"]
    other_fields = [] unless other_fields.kind_of? Array
    other_fields.delete_if {|field| field.to_s == "" }

    response['Content-Type'] = "text/csv; charset=utf-8"
    response['Content-Disposition'] = "attachment; filename=ankiverse.csv"

    FasterCSV.generate do |csv|
      (lines.size - 2).times do |i|
        csv << [
          lines[[0, i-3].max..i].join("<br/>") + "<br/>...", # 4 prev lines
          lines[i + 1, 2].join("<br/>"),                     # 2 next lines
          *other_fields
        ]
      end
    end

  end

  get '/bible/:passage' do
    options = {
      :key => "IP",
      :output_format => "plain-text",
      :line_length => 0,
      :dont_include => %w(
        passage-references
        first-verse-numbers
        verse-numbers
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

    response = EsvApiRequest.execute(:passageQuery,
      options.merge(:passage => params[:passage]))

    @passage = params[:passage]
    @poem = SentenceSplitter.new(response).lines_of(5..12).join("\n")
    @other_fields = [@passage]
    erb :index
  end

end
