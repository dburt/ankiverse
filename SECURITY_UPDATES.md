# Security Updates Needed

## Summary

This project has several dependencies with known security vulnerabilities that should be updated.

## Critical Vulnerabilities Found

### 1. Rack 3.0.10 → **Upgrade to 3.0.16+**
**Status: CRITICAL** - Multiple high-severity vulnerabilities

- **CVE-2025-27610** (CVSS 7.5 - High)
  - Path traversal vulnerability in Rack::Static
  - Attackers can access files outside the designated static file directory
  - Can expose configuration files, credentials, and sensitive data
  - Fixed in: 3.0.14, 3.1.12

- **CVE-2025-46727** (CVSS 7.5 - High)
  - Unbounded parameter DoS in Rack::QueryParser
  - Can cause memory exhaustion or pin CPU resources
  - Results in service disruption
  - Fixed in: 3.0.16, 3.1.14

- **CVE-2025-25184** (CVSS 5.7 - Medium)
  - Log injection in Rack::CommonLogger
  - Fixed in: 3.0.12, 3.1.10

- **CVE-2025-27111** (CVSS 6.9 - Medium)
  - Log injection in Rack::Sendfile
  - Fixed in: 3.0.12, 3.1.10

### 2. Puma 6.4.2 → **Upgrade to 6.4.3+**
**Status: MEDIUM** - Header clobbering vulnerability

- **CVE-2024-45614**
  - Clients can clobber proxy-set headers (e.g., X-Forwarded-For)
  - Affects applications relying on proxy-set variables
  - Fixed in: 6.4.3, 5.6.9

### 3. Nokogiri 1.16.4 → **Upgrade to 1.17.2+**
**Status: MEDIUM** - Underlying library vulnerabilities

- **CVE-2024-55549, CVE-2025-24855** - libxslt vulnerabilities
- **CVE-2025-24928, CVE-2024-56171** - libxml2 vulnerabilities
- **CVE-2024-40896** - Additional libxml2 issue
- **CVE-2024-34459** - Heap-based buffer overflow

## Recommended Actions

Update `Gemfile` to specify minimum secure versions:

```ruby
gem 'nokogiri', '>= 1.17.2'  # Security: Multiple CVEs in libxml2/libxslt
gem 'puma', '>= 6.4.3'        # Security: CVE-2024-45614
gem 'rack', '>= 3.0.16'       # Security: Multiple critical CVEs
```

Then run:
```bash
bundle update nokogiri puma rack
```

## References

- [Nokogiri Security Advisories](https://security.snyk.io/package/rubygems/nokogiri)
- [Puma Security Advisories](https://security.snyk.io/package/rubygems/puma)
- [Rack Security Advisories](https://www.cvedetails.com/vulnerability-list/vendor_id-12598/product_id-24629/Rack-Project-Rack.html)
- [CVE-2024-45614 Details](https://rubysec.com/advisories/CVE-2024-45614/)
- [CVE-2025-27610 Details](https://www.helpnetsecurity.com/2025/04/25/rack-ruby-vulnerability-could-reveal-secrets-to-attackers-cve-2025-27610/)
- [CVE-2025-46727 Details](https://rubysec.com/advisories/CVE-2025-46727/)
