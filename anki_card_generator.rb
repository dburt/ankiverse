
class AnkiCardGenerator
  attr_accessor :poem, :other_fields

  def initialize(poem, other_fields)
    @poem = poem.to_s
    @other_fields = [*other_fields].select {|field| field.to_s != "" }
  end

  def lines
    @lines ||= begin
      iconv = Iconv.new('UTF-8', 'WINDOWS-1252')
      poem.strip.split(/\r?\n/).map do |line|
        iconv.iconv line.strip
      end
    end
  end

  def csv(options = {})
    # future options: :ellipsis, :lines
    CSV.generate do |csv|
      (lines.size - 2).times do |i|
        csv << [
          lines[[0, i-3].max..i].join("<br/>") + "<br/>" +   # 4 prev lines
            (options[:ellipsis] == false ? "" : "..."),
          lines[i + 1, 2].join("<br/>"),                     # 2 next lines
          *other_fields
        ]
      end
    end
  end
end
