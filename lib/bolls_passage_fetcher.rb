require 'faraday'
require 'json'

# Fetches Bible passages from bolls.life API
# Supports many translations: KJV, NKJV, CJB, TLV, NASB, ESV, NIV, NLT, and more
# No API key required
class BollsPassageFetcher
  attr_reader :text

  # Mapping of common book names to bolls.life book IDs (1-66)
  BOOK_IDS = {
    'genesis' => 1, 'gen' => 1,
    'exodus' => 2, 'exo' => 2, 'ex' => 2,
    'leviticus' => 3, 'lev' => 3,
    'numbers' => 4, 'num' => 4,
    'deuteronomy' => 5, 'deu' => 5, 'deut' => 5,
    'joshua' => 6, 'jos' => 6, 'josh' => 6,
    'judges' => 7, 'jdg' => 7, 'judg' => 7,
    'ruth' => 8, 'rut' => 8,
    '1 samuel' => 9, '1samuel' => 9, '1sam' => 9, '1 sam' => 9,
    '2 samuel' => 10, '2samuel' => 10, '2sam' => 10, '2 sam' => 10,
    '1 kings' => 11, '1kings' => 11, '1kgs' => 11, '1 kgs' => 11,
    '2 kings' => 12, '2kings' => 12, '2kgs' => 12, '2 kgs' => 12,
    '1 chronicles' => 13, '1chronicles' => 13, '1chr' => 13, '1 chr' => 13,
    '2 chronicles' => 14, '2chronicles' => 14, '2chr' => 14, '2 chr' => 14,
    'ezra' => 15, 'ezr' => 15,
    'nehemiah' => 16, 'neh' => 16,
    'esther' => 17, 'est' => 17,
    'job' => 18,
    'psalm' => 19, 'psalms' => 19, 'ps' => 19, 'psa' => 19,
    'proverbs' => 20, 'pro' => 20, 'prov' => 20,
    'ecclesiastes' => 21, 'ecc' => 21, 'eccl' => 21,
    'song of solomon' => 22, 'song' => 22, 'sos' => 22,
    'isaiah' => 23, 'isa' => 23,
    'jeremiah' => 24, 'jer' => 24,
    'lamentations' => 25, 'lam' => 25,
    'ezekiel' => 26, 'eze' => 26, 'ezek' => 26,
    'daniel' => 27, 'dan' => 27,
    'hosea' => 28, 'hos' => 28,
    'joel' => 29, 'joe' => 29,
    'amos' => 30, 'amo' => 30,
    'obadiah' => 31, 'oba' => 31, 'obad' => 31,
    'jonah' => 32, 'jon' => 32,
    'micah' => 33, 'mic' => 33,
    'nahum' => 34, 'nah' => 34,
    'habakkuk' => 35, 'hab' => 35,
    'zephaniah' => 36, 'zep' => 36, 'zeph' => 36,
    'haggai' => 37, 'hag' => 37,
    'zechariah' => 38, 'zec' => 38, 'zech' => 38,
    'malachi' => 39, 'mal' => 39,
    'matthew' => 40, 'mat' => 40, 'matt' => 40, 'mt' => 40,
    'mark' => 41, 'mar' => 41, 'mrk' => 41, 'mk' => 41,
    'luke' => 42, 'luk' => 42, 'lk' => 42,
    'john' => 43, 'joh' => 43, 'jhn' => 43,
    'acts' => 44, 'act' => 44,
    'romans' => 45, 'rom' => 45,
    '1 corinthians' => 46, '1corinthians' => 46, '1cor' => 46, '1 cor' => 46,
    '2 corinthians' => 47, '2corinthians' => 47, '2cor' => 47, '2 cor' => 47,
    'galatians' => 48, 'gal' => 48,
    'ephesians' => 49, 'eph' => 49,
    'philippians' => 50, 'phi' => 50, 'phil' => 50,
    'colossians' => 51, 'col' => 51,
    '1 thessalonians' => 52, '1thessalonians' => 52, '1thess' => 52, '1 thess' => 52, '1th' => 52, '1 th' => 52,
    '2 thessalonians' => 53, '2thessalonians' => 53, '2thess' => 53, '2 thess' => 53, '2th' => 53, '2 th' => 53,
    '1 timothy' => 54, '1timothy' => 54, '1tim' => 54, '1 tim' => 54,
    '2 timothy' => 55, '2timothy' => 55, '2tim' => 55, '2 tim' => 55,
    'titus' => 56, 'tit' => 56,
    'philemon' => 57, 'phm' => 57, 'phlm' => 57,
    'hebrews' => 58, 'heb' => 58,
    'james' => 59, 'jam' => 59, 'jas' => 59,
    '1 peter' => 60, '1peter' => 60, '1pet' => 60, '1 pet' => 60, '1pe' => 60, '1 pe' => 60,
    '2 peter' => 61, '2peter' => 61, '2pet' => 61, '2 pet' => 61, '2pe' => 61, '2 pe' => 61,
    '1 john' => 62, '1john' => 62, '1joh' => 62, '1 joh' => 62, '1jn' => 62, '1 jn' => 62,
    '2 john' => 63, '2john' => 63, '2joh' => 63, '2 joh' => 63, '2jn' => 63, '2 jn' => 63,
    '3 john' => 64, '3john' => 64, '3joh' => 64, '3 joh' => 64, '3jn' => 64, '3 jn' => 64,
    'jude' => 65, 'jud' => 65,
    'revelation' => 66, 'rev' => 66
  }


  def initialize(passage, options = {})
    @passage = passage
    @translation = options[:translation] || 'kjv'  # Default to KJV
    @verse_numbers = options[:verse_numbers]
    @text = nil
    @json_responses = []
  end

  def self.fetch(passage, options = {})
    fetcher = new(passage, options)
    fetcher.fetch
    fetcher.clean
    fetcher.text
  end

  def fetch
    # Parse the passage (e.g., "John 3:16", "Psalm 23:1-6", "Genesis 1")
    book_name, chapter, verses = parse_passage(@passage)
    book_id = BOOK_IDS[book_name.downcase]

    raise "Unknown book: #{book_name}" unless book_id

    # Determine verse range
    if verses
      start_verse, end_verse = verses.split('-').map(&:to_i)
      end_verse ||= start_verse
      verse_range = (start_verse..end_verse).to_a
    else
      # If no verses specified, we'll need to fetch the whole chapter
      # For simplicity, let's assume verses 1-50 (we'll filter out nil responses)
      verse_range = (1..50).to_a
    end

    # Fetch each verse
    conn = Faraday.new(url: 'https://bolls.life')

    verse_range.each do |verse|
      response = conn.get("/get-verse/#{@translation.upcase}/#{book_id}/#{chapter}/#{verse}/")

      if response.success?
        json = JSON.parse(response.body)
        @json_responses << json if json && json['text']
      end
    end

    # If we didn't get any responses, raise an error
    raise "Failed to fetch passage from bolls.life" if @json_responses.empty?

    self
  end

  def clean
    return unless @json_responses.any?

    # Parse the original passage to get book name and chapter
    book_name, chapter, _ = parse_passage(@passage)
    translation_name = @translation.upcase

    # Build reference from request params and response verse numbers
    verses = @json_responses.map { |v| v['verse'] }
    if verses.length == 1
      reference = "#{book_name} #{chapter}:#{verses.first}"
    else
      reference = "#{book_name} #{chapter}:#{verses.first}-#{verses.last}"
    end

    # Build the text with prefix
    @text = "#{reference} (#{translation_name})\n"

    # Add each verse
    @json_responses.each do |verse_data|
      verse_text = verse_data['text'].strip
      # Remove Strong's number tags (e.g. <S>1063</S>) and any other HTML tags
      verse_text = verse_text.gsub(/<S>[^<]*<\/S>/, '').gsub(/<[^>]*>/, '')

      if @verse_numbers
        @text += "#{verse_data['verse']} #{verse_text}\n"
      else
        @text += "#{verse_text}\n"
      end
    end

    # Add suffix with reference
    @text += "#{reference} (#{translation_name})"

    self
  end

  private

  def parse_passage(passage)
    # Examples: "John 3:16", "Psalm 23:1-6", "Genesis 1", "1 Corinthians 13:4-8"
    # Pattern: (Book name) (chapter):(verse or verse range)
    match = passage.match(/^([\d\s]*[a-zA-Z\s]+?)\s*(\d+)(?::(\d+(?:-\d+)?))?$/i)

    raise "Invalid passage format: #{passage}" unless match

    book_name = match[1].strip
    chapter = match[2].to_i
    verses = match[3]

    [book_name, chapter, verses]
  end
end

# Allow running this file directly for testing
if __FILE__ == $0
  if ARGV.length == 0
    puts "Usage: ruby bolls_passage_fetcher.rb 'passage' [translation]"
    puts "Example: ruby bolls_passage_fetcher.rb 'John 3:16' kjv"
    exit 1
  end

  passage = ARGV[0]
  translation = ARGV[1] || 'kjv'

  puts BollsPassageFetcher.fetch(passage, translation: translation)
end
