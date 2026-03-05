# SubstackAuto Design Document

Date: 2026-03-05

## Problem

Manual workflow: open Substack articles, paste into LLM, read summary, look up tickers. Want this fully automated with structured digests delivered via Telegram.

## System Architecture

```
Poller (APScheduler, every 15 min)
  |
  v
RSS Feeds (feedparser) -- detect new articles
  |
  v
Substack API (httpx + cookie) -- fetch full body_html
  |
  v
html2text -- convert to Markdown
  |
  v
Claude CLI (subprocess) -- structured summary + ticker extraction
  |
  v
yfinance -- enrich each ticker with valuation data
  |
  v
Formatter -- build Telegram message
  |
  v
Telegram Bot (python-telegram-bot) -- deliver to user
  |
  v
SQLite -- mark article as processed
```

## Tech Stack

- Language: Python
- Scheduler: APScheduler 3.x
- RSS: feedparser
- HTTP: httpx
- HTML to text: html2text
- LLM: Claude CLI via subprocess.run()
- Financial data: yfinance
- Telegram: python-telegram-bot
- Persistence: SQLite
- Config: YAML

## Substack Content Access

Validated through live testing:

### RSS Feeds
- Every publication has a `/feed` endpoint
- Returns 20 most recent articles with title, slug, date, URL
- Used for new article detection only (content is preview-only for paid articles)

### Full Article Fetching
- Endpoint: `{base_url}/api/v1/posts/{slug}`
- Returns JSON with `body_html` field containing full article (including content after paywall marker)
- `wordcount` field used to verify completeness

### Authentication (Cookies)
- `*.substack.com` publications: `substack.sid` cookie (universal, set on `.substack.com` domain)
- Custom domain publications: `connect.sid` cookie (per-domain, must be grabbed from browser per site)
- Both expire in ~3 months
- App detects expired cookies by comparing extracted word count to `wordcount` field

### Tested Publications

| Publication | Type | Cookie | Result |
|---|---|---|---|
| thefinancecorner.substack.com | Subdomain | substack.sid | Full text |
| archetype-research.com | Custom domain | connect.sid | Full text |
| yetanothervalueblog.com | Custom domain | connect.sid | Full text |

## Configuration

```yaml
publications:
  - name: "Archetype Capital"
    feed_url: "https://www.archetype-research.com/feed"
    api_base: "https://www.archetype-research.com"
    cookie_type: "connect.sid"
  - name: "The Finance Corner"
    feed_url: "https://thefinancecorner.substack.com/feed"
    api_base: "https://thefinancecorner.substack.com"
    cookie_type: "substack.sid"
  - name: "Yet Another Value Blog"
    feed_url: "https://www.yetanothervalueblog.com/feed"
    api_base: "https://www.yetanothervalueblog.com"
    cookie_type: "connect.sid"

auth:
  substack_sid: "<value>"
  connect_sids:
    www.archetype-research.com: "<value>"
    www.yetanothervalueblog.com: "<value>"

telegram:
  bot_token: "<value>"
  chat_id: "<value>"

polling:
  interval_minutes: 15

claude:
  model: "sonnet"
```

## Components

### 1. Poller (poller.py)
- APScheduler job runs every 15 minutes
- For each publication: fetch RSS feed via feedparser
- Extract article slug from URL, check against SQLite
- Queue new articles for processing

### 2. Fetcher (fetcher.py)
- Call `{api_base}/api/v1/posts/{slug}` with appropriate cookie
- Return body_html, title, date, wordcount, audience
- Detect cookie expiration: if extracted words < wordcount * 0.8, flag as expired
- On expiration: send Telegram alert, skip article

### 3. Summarizer (summarizer.py)
- Convert body_html to Markdown via html2text
- Call Claude CLI: `claude --print --model {model} -p "{prompt}"`
- Prompt requests structured JSON output:
  - tldr (2-3 sentences)
  - key_arguments (list)
  - key_data_points (list)
  - actionable_takeaways (list)
  - tickers (list of {symbol, context})
- Tickers in Yahoo Finance format (e.g. 4063.T, BETS-B.ST, 0700.HK, DJCO)
- subprocess.run() with timeout=120

### 4. Enricher (enricher.py)
- For each ticker from summarizer: call yfinance
- Extract: shortName, sector, currency, currentPrice, marketCap, enterpriseValue
- Pre-computed multiples: trailingPE, enterpriseToEbitda, enterpriseToRevenue
- Calculate P/FCF = marketCap / freeCashflow
- If ticker not found: skip, note in output
- Send computed multiples to Claude for brief valuation commentary (cheap/fair/expensive vs sector)

### 5. Formatter (formatter.py)
- Build structured Telegram message:
  - Header: publication name, article title, date
  - Summary: TL;DR, key arguments, data points, takeaways
  - Per-ticker cards: name, sector, currency, price, mcap, EV, multiples, valuation comment
  - Footer: link to original article
- Split messages at 4096 char limit on section boundaries

### 6. Sender (sender.py)
- python-telegram-bot library
- Send message(s) to configured chat_id
- HTML parse mode for formatting

### 7. DB (db.py)
- SQLite database at data/articles.db
- Table: articles(id INTEGER PRIMARY KEY, url TEXT UNIQUE, title TEXT, pub_name TEXT, processed_at TEXT)
- Check before processing: SELECT by url
- Insert after successful delivery

### 8. Main (main.py)
- Load config.yaml
- Initialize SQLite
- Set up APScheduler with polling job
- Run indefinitely

## Project Structure

```
substackauto/
  config.yaml
  main.py
  poller.py
  fetcher.py
  summarizer.py
  enricher.py
  formatter.py
  sender.py
  db.py
  requirements.txt
  data/
    articles.db
```

## Failure Modes

| Failure | Detection | Handling |
|---|---|---|
| Cookie expired | word count mismatch | Telegram alert, skip article, retry next cycle |
| Claude CLI hangs | subprocess timeout (120s) | Kill process, skip article, retry next cycle |
| Claude CLI not installed | subprocess FileNotFoundError | Log error, exit |
| yfinance ticker not found | empty/error response | Skip ticker enrichment, note in message |
| Telegram message too long | len > 4096 | Split on section boundaries |
| RSS feed down | HTTP error / parse error | Log, skip feed, process other feeds |
| Duplicate article | SQLite UNIQUE constraint on url | Skip silently |
| Substack API 404 | HTTP 404 | Log, skip article |
| Network error | httpx exception | Log, retry next cycle |

## Deployment (VPS)

- Cheap VPS (DigitalOcean $5/mo or Hetzner)
- Install: Python 3.11+, Claude CLI (npm install -g @anthropic-ai/claude-code), authenticate (claude auth login)
- systemd service for always-on operation
- Config file with secrets stored outside git

## Future Considerations (not in scope)

- Web UI for managing publications
- Multiple Telegram recipients
- Article search/archive beyond Telegram history
- Automatic cookie refresh
