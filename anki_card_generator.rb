
class AnkiCardGenerator
  attr_accessor :poem, :other_fields

  def initialize(poem, other_fields)
    @poem = poem.to_s
    @other_fields = [*other_fields].select {|field| field.to_s != "" }
  end

  def lines
    @lines ||= begin
      poem.strip.split(/\r?\n/).map do |line|
        line.strip
      end
    end
  end

  def csv(options = {})
    # future options: :ellipsis, :lines
    q_lines, a_lines = options[:lines]
    unless (1..20).include?(q_lines) && (1..20).include?(a_lines)
      raise ArgumentError, "the numbers of lines need to be numbers"
    end
    CSV.generate do |csv|
      (lines.size - a_lines).times do |i|
        csv << [
          lines[[0, i-q_lines+1].max..i].join("<br/>") +   # 4 prev lines
            "<br/>" +
            (options[:ellipsis] == false ? "" : "..."),
          lines[i + 1, a_lines].join("<br/>"),             # 2 next lines
          *other_fields
        ]
      end
    end
  end
end
