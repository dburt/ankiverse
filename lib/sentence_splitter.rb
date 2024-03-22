#
# Split a sentence into lines of a particular length, preferring to break
# at natural places (i.e. punctuation and conjunctions).
#
class SentenceSplitter
  def initialize(str)
    @sentences = str.scan(/\S.*?(?:[.?!]\S*|$)/).grep(/\w/)
  end

  #
  # range is a Range specifying the number of words to be in each line.
  # Its #last must be at least double its #first.
  #
  def lines_of(range)
    min_words = range.first
    max_words = range.last
    raise ArgumentError, "Invalid range" if max_words < min_words * 2
    words_left = 0
    line = []

    @sentences.inject([]) do |result, sentence|
      too_few_words = proc { line.size < min_words || words_left < min_words }
      too_many_words = proc { line.size >= max_words ||
        line.size + words_left > max_words && words_left <= min_words }
      end_line = proc { result << line.join(" ") and line.clear }
      words = sentence.split
      word_count = words.size

      next result << sentence if word_count < min_words * 2

      line.clear
      words.each_with_index do |word, i|
        words_left = word_count - i
        if too_few_words[]
          line << word
          end_line.call if word =~ /[,;]$/ && !too_few_words[]
        elsif too_many_words[] || word =~ /^['"]|^(and|that|or|for|nor|if)$/
          end_line.call
          line << word
        elsif word =~ /[,;]$/
          line << word
          end_line.call
        else
          line << word
        end
      end
      result << line.join(" ")
    end
  end
end
