#!/usr/bin/ruby -w

require 'rubygems'
require 'sinatra'
require 'fastercsv'
require 'iconv'

class AnkiVerse < Sinatra::Base

  #get '/' do
  ## handled by index.html
  #end

  post '/' do

    iconv = Iconv.new('UTF-8', 'WINDOWS-1252')
    lines = request.params["poem"].to_s.strip.split(/\r?\n/)
    lines.map! do |line|
      iconv.iconv line.strip
    end

    response['Content-Type'] = "text/csv; charset=utf-8"
    response['Content-Disposition'] = "attachment; filename=ankiverse.csv"

    FasterCSV.generate do |csv|
      (lines.size - 2).times do |i|
        csv << [
          lines[[0, i-3].max..i].join("<br/>") + "<br/>...", # 4 prev lines
          lines[i + 1, 2].join("<br/>") ]                    # 2 next lines
      end
    end

  end

end
