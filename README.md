# Ankiverse: Memorize poetry with Anki

Ankiverse is a simple web app that breaks lines of text into Anki cards in CSV
format in the following form:

> Line 1  
> Line 2  
> Line 3  
> Line 4  
>
> ------  
> Line 5  
> Line 6

This means the prompt for each line is its immediate context, and also provides
overlap between memorized lines.

The number of lines on front and back are customizable, and the app can also
fetch Bible passages and automatically split them up into sensible lines.

The technique is derived from the examples on this page:
http://www.supermemo.com/help/faq/ks.htm#348-5403
and
http://www.supermemo.com/help/faq/ks.htm#sequences

## Supported Bible Versions

Ankiverse supports fetching Bible passages from multiple sources with different translations:

- **NIV** (New International Version) - via BibleGateway.com
- **ESV** (English Standard Version) - via ESV API (requires API key in `.env` file)
- **WEB** (World English Bible) - via bible-api.com (no API key required)
- **KJV** (King James Version) - via bolls.life API (no API key required)

### Setting up ESV API

To use the ESV version, you need to:
1. Get a free API key from https://api.esv.org/
2. Create a `.env` file in the project root
3. Add your API key: `ESV_API_KEY=your_key_here`

## Running Tests

Run the unit tests:
```bash
ruby -Ilib:test test/*_test.rb
```

Run integration tests (requires internet connection):
```bash
INTEGRATION_TESTS=true ruby -Ilib:test test/*_integration_test.rb
```

## Security

See [SECURITY_UPDATES.md](SECURITY_UPDATES.md) for information about security vulnerabilities and recommended dependency updates.

## To Do

* Generate serial numbers and verse numbers
