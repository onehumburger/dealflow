# SubstackAuto Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Automated pipeline that monitors Substack publications, summarizes articles with Claude, enriches stock tickers with financial data, and delivers structured digests via Telegram.

**Architecture:** Polling-based pipeline. APScheduler checks RSS feeds every 15 min, fetches full article content via Substack API with session cookies, summarizes via Claude CLI subprocess, enriches tickers via yfinance, delivers via Telegram bot. SQLite tracks processed articles.

**Tech Stack:** Python 3.11+, APScheduler 3.x, feedparser, httpx, html2text, yfinance, python-telegram-bot, SQLite, PyYAML

**Design doc:** `docs/plans/2026-03-05-substackauto-design.md`

---

### Task 1: Project Setup

**Files:**
- Create: `requirements.txt`
- Create: `config.yaml.example`

**Step 1: Create requirements.txt**

```
apscheduler>=3.10.0
feedparser>=6.0.0
httpx>=0.27.0
html2text>=2024.2.26
yfinance>=0.2.40
python-telegram-bot>=21.0
pyyaml>=6.0
```

**Step 2: Create config.yaml.example**

```yaml
publications:
  - name: "The Finance Corner"
    feed_url: "https://thefinancecorner.substack.com/feed"
    api_base: "https://thefinancecorner.substack.com"
    cookie_type: "substack.sid"
  - name: "Archetype Capital"
    feed_url: "https://www.archetype-research.com/feed"
    api_base: "https://www.archetype-research.com"
    cookie_type: "connect.sid"

auth:
  substack_sid: "YOUR_SUBSTACK_SID_HERE"
  connect_sids:
    www.archetype-research.com: "YOUR_CONNECT_SID_HERE"

telegram:
  bot_token: "YOUR_BOT_TOKEN"
  chat_id: "YOUR_CHAT_ID"

polling:
  interval_minutes: 15

claude:
  model: "sonnet"
```

**Step 3: Set up virtual environment and install**

Run:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
Expected: All packages install successfully.

**Step 4: Create .gitignore**

```
.venv/
data/
config.yaml
__pycache__/
*.pyc
```

**Step 5: Commit**

```bash
git add requirements.txt config.yaml.example .gitignore
git commit -m "feat: project setup with dependencies and config template"
```

---

### Task 2: Database Layer (db.py)

**Files:**
- Create: `tests/test_db.py`
- Create: `db.py`

**Step 1: Write failing tests**

```python
# tests/test_db.py
import os
import pytest
from db import ArticleDB

@pytest.fixture
def db(tmp_path):
    db_path = tmp_path / "test.db"
    return ArticleDB(str(db_path))

def test_is_seen_returns_false_for_new_url(db):
    assert db.is_seen("https://example.com/p/article-1") is False

def test_mark_seen_then_is_seen_returns_true(db):
    db.mark_seen("https://example.com/p/article-1", "Article 1", "Test Pub")
    assert db.is_seen("https://example.com/p/article-1") is True

def test_mark_seen_duplicate_does_not_raise(db):
    db.mark_seen("https://example.com/p/article-1", "Article 1", "Test Pub")
    db.mark_seen("https://example.com/p/article-1", "Article 1", "Test Pub")
    assert db.is_seen("https://example.com/p/article-1") is True

def test_different_urls_are_independent(db):
    db.mark_seen("https://example.com/p/article-1", "Article 1", "Test Pub")
    assert db.is_seen("https://example.com/p/article-2") is False
```

**Step 2: Run tests to verify they fail**

Run: `pytest tests/test_db.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'db'`

**Step 3: Implement db.py**

```python
# db.py
import sqlite3
from datetime import datetime, timezone


class ArticleDB:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)
        self.conn.execute(
            "CREATE TABLE IF NOT EXISTS articles ("
            "  id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  url TEXT UNIQUE NOT NULL,"
            "  title TEXT,"
            "  pub_name TEXT,"
            "  processed_at TEXT"
            ")"
        )
        self.conn.commit()

    def is_seen(self, url: str) -> bool:
        row = self.conn.execute(
            "SELECT 1 FROM articles WHERE url = ?", (url,)
        ).fetchone()
        return row is not None

    def mark_seen(self, url: str, title: str, pub_name: str):
        self.conn.execute(
            "INSERT OR IGNORE INTO articles (url, title, pub_name, processed_at) "
            "VALUES (?, ?, ?, ?)",
            (url, title, pub_name, datetime.now(timezone.utc).isoformat()),
        )
        self.conn.commit()
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_db.py -v`
Expected: 4 passed

**Step 5: Commit**

```bash
git add db.py tests/test_db.py
git commit -m "feat: add SQLite article tracking"
```

---

### Task 3: RSS Poller (poller.py)

**Files:**
- Create: `tests/test_poller.py`
- Create: `poller.py`

**Step 1: Write failing tests**

```python
# tests/test_poller.py
import pytest
from unittest.mock import patch, MagicMock
from poller import parse_feed, extract_slug

def test_extract_slug_from_substack_url():
    url = "https://thefinancecorner.substack.com/p/deep-dive-into-verisign"
    assert extract_slug(url) == "deep-dive-into-verisign"

def test_extract_slug_from_custom_domain():
    url = "https://www.archetype-research.com/p/2-top-japan-picks"
    assert extract_slug(url) == "2-top-japan-picks"

def test_extract_slug_ignores_query_params():
    url = "https://example.substack.com/p/my-article?utm_source=feed"
    assert extract_slug(url) == "my-article"

def test_parse_feed_returns_articles():
    # Use a minimal valid RSS XML
    rss_xml = """<?xml version="1.0"?>
    <rss version="2.0">
      <channel>
        <item>
          <title>Test Article</title>
          <link>https://example.substack.com/p/test-article</link>
          <pubDate>Thu, 05 Mar 2026 07:00:00 GMT</pubDate>
        </item>
      </channel>
    </rss>"""
    with patch("poller.feedparser.parse") as mock_parse:
        mock_parse.return_value = MagicMock(
            entries=[
                MagicMock(
                    title="Test Article",
                    link="https://example.substack.com/p/test-article",
                    published="Thu, 05 Mar 2026 07:00:00 GMT",
                )
            ]
        )
        articles = parse_feed("https://example.substack.com/feed")
        assert len(articles) == 1
        assert articles[0]["title"] == "Test Article"
        assert articles[0]["slug"] == "test-article"
        assert articles[0]["url"] == "https://example.substack.com/p/test-article"
```

**Step 2: Run tests to verify they fail**

Run: `pytest tests/test_poller.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'poller'`

**Step 3: Implement poller.py**

```python
# poller.py
from urllib.parse import urlparse
import feedparser


def extract_slug(url: str) -> str:
    path = urlparse(url).path
    # URL format: /p/{slug}
    parts = path.strip("/").split("/")
    if len(parts) >= 2 and parts[0] == "p":
        return parts[1]
    return parts[-1]


def parse_feed(feed_url: str) -> list[dict]:
    feed = feedparser.parse(feed_url)
    articles = []
    for entry in feed.entries:
        articles.append({
            "title": entry.title,
            "url": entry.link,
            "slug": extract_slug(entry.link),
            "published": getattr(entry, "published", ""),
        })
    return articles
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_poller.py -v`
Expected: 4 passed

**Step 5: Commit**

```bash
git add poller.py tests/test_poller.py
git commit -m "feat: add RSS feed polling and slug extraction"
```

---

### Task 4: Article Fetcher (fetcher.py)

**Files:**
- Create: `tests/test_fetcher.py`
- Create: `fetcher.py`

**Step 1: Write failing tests**

```python
# tests/test_fetcher.py
import pytest
from unittest.mock import patch, MagicMock, AsyncMock
import json
from fetcher import fetch_article, get_cookie_header, extract_text

def test_get_cookie_header_substack_sid():
    auth = {"substack_sid": "abc123", "connect_sids": {}}
    pub = {"cookie_type": "substack.sid", "api_base": "https://x.substack.com"}
    assert get_cookie_header(auth, pub) == "substack.sid=abc123"

def test_get_cookie_header_connect_sid():
    auth = {
        "substack_sid": "abc",
        "connect_sids": {"www.example.com": "def456"},
    }
    pub = {"cookie_type": "connect.sid", "api_base": "https://www.example.com"}
    assert get_cookie_header(auth, pub) == "connect.sid=def456; substack.sid=abc"

def test_extract_text_strips_html():
    html = "<p>Hello <b>world</b></p>"
    text = extract_text(html)
    assert "Hello" in text
    assert "world" in text
    assert "<p>" not in text

def test_extract_text_preserves_content_after_paywall():
    html = '<p>Before</p><div class="paywall">wall</div><p>After paywall content</p>'
    text = extract_text(html)
    assert "Before" in text
    assert "After paywall content" in text
```

**Step 2: Run tests to verify they fail**

Run: `pytest tests/test_fetcher.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'fetcher'`

**Step 3: Implement fetcher.py**

```python
# fetcher.py
from urllib.parse import urlparse
import httpx
import html2text

_h2t = html2text.HTML2Text()
_h2t.ignore_links = False
_h2t.ignore_images = True
_h2t.body_width = 0

USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
)


def get_cookie_header(auth: dict, pub: dict) -> str:
    if pub["cookie_type"] == "substack.sid":
        return f"substack.sid={auth['substack_sid']}"
    # Custom domain: send both connect.sid and substack.sid
    domain = urlparse(pub["api_base"]).hostname
    connect_sid = auth["connect_sids"].get(domain, "")
    parts = [f"connect.sid={connect_sid}"]
    if auth.get("substack_sid"):
        parts.append(f"substack.sid={auth['substack_sid']}")
    return "; ".join(parts)


def extract_text(body_html: str) -> str:
    return _h2t.handle(body_html)


def fetch_article(api_base: str, slug: str, auth: dict, pub: dict) -> dict | None:
    url = f"{api_base}/api/v1/posts/{slug}"
    cookie = get_cookie_header(auth, pub)
    resp = httpx.get(
        url,
        headers={"Cookie": cookie, "User-Agent": USER_AGENT},
        timeout=30,
    )
    if resp.status_code != 200:
        return None
    data = resp.json()
    body_html = data.get("body_html", "")
    text = extract_text(body_html)
    word_count = len(text.split())
    expected_wc = data.get("wordcount", 0)
    return {
        "title": data.get("title", ""),
        "subtitle": data.get("description", ""),
        "date": data.get("post_date", ""),
        "audience": data.get("audience", "everyone"),
        "wordcount": expected_wc,
        "fetched_wordcount": word_count,
        "body_markdown": text,
        "cookie_ok": word_count >= expected_wc * 0.8 if expected_wc > 0 else True,
    }
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_fetcher.py -v`
Expected: 4 passed

**Step 5: Commit**

```bash
git add fetcher.py tests/test_fetcher.py
git commit -m "feat: add Substack article fetcher with cookie auth"
```

---

### Task 5: Summarizer (summarizer.py)

**Files:**
- Create: `tests/test_summarizer.py`
- Create: `summarizer.py`

**Step 1: Write failing tests**

```python
# tests/test_summarizer.py
import json
import pytest
from unittest.mock import patch, MagicMock
from summarizer import summarize_article, build_prompt, parse_response

def test_build_prompt_includes_article():
    prompt = build_prompt("This is the article text about $AAPL and $TSLA.")
    assert "This is the article text" in prompt
    assert "Yahoo Finance format" in prompt
    assert "tldr" in prompt

def test_parse_response_valid_json():
    response = json.dumps({
        "tldr": "Summary here",
        "key_arguments": ["arg1"],
        "key_data_points": ["data1"],
        "actionable_takeaways": ["action1"],
        "tickers": [{"symbol": "AAPL", "context": "mentioned as example"}],
    })
    result = parse_response(response)
    assert result["tldr"] == "Summary here"
    assert len(result["tickers"]) == 1
    assert result["tickers"][0]["symbol"] == "AAPL"

def test_parse_response_json_in_markdown_block():
    response = '```json\n{"tldr": "Summary", "key_arguments": [], "key_data_points": [], "actionable_takeaways": [], "tickers": []}\n```'
    result = parse_response(response)
    assert result["tldr"] == "Summary"

def test_parse_response_invalid_json_returns_none():
    result = parse_response("This is not JSON at all")
    assert result is None
```

**Step 2: Run tests to verify they fail**

Run: `pytest tests/test_summarizer.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'summarizer'`

**Step 3: Implement summarizer.py**

```python
# summarizer.py
import json
import re
import subprocess


def build_prompt(article_markdown: str) -> str:
    return f"""Analyze this article and return ONLY valid JSON with this exact structure:
{{
  "tldr": "2-3 sentence summary",
  "key_arguments": ["argument 1", "argument 2"],
  "key_data_points": ["data point 1", "data point 2"],
  "actionable_takeaways": ["takeaway 1", "takeaway 2"],
  "tickers": [
    {{"symbol": "AAPL", "context": "why this ticker is mentioned"}}
  ]
}}

For tickers: use Yahoo Finance format. US tickers have no suffix (e.g. AAPL). International tickers need exchange suffix (e.g. 4063.T for Tokyo, BETS-B.ST for Stockholm, 0700.HK for Hong Kong, ASML.AS for Amsterdam).

Only include tickers that are actually discussed in the article, not just casually mentioned.

Article:
{article_markdown}"""


def parse_response(response: str) -> dict | None:
    # Try direct JSON parse
    try:
        return json.loads(response)
    except json.JSONDecodeError:
        pass
    # Try extracting from markdown code block
    match = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", response, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass
    return None


def summarize_article(article_markdown: str, model: str = "sonnet") -> dict | None:
    prompt = build_prompt(article_markdown)
    try:
        result = subprocess.run(
            ["claude", "--print", "--model", model, "-p", prompt],
            capture_output=True,
            text=True,
            timeout=120,
        )
        if result.returncode != 0:
            return None
        return parse_response(result.stdout)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_summarizer.py -v`
Expected: 4 passed

**Step 5: Commit**

```bash
git add summarizer.py tests/test_summarizer.py
git commit -m "feat: add Claude CLI summarizer with JSON parsing"
```

---

### Task 6: Ticker Enricher (enricher.py)

**Files:**
- Create: `tests/test_enricher.py`
- Create: `enricher.py`

**Step 1: Write failing tests**

```python
# tests/test_enricher.py
import pytest
from unittest.mock import patch, MagicMock
from enricher import enrich_ticker, format_number

def test_format_number_millions():
    assert format_number(1_500_000) == "1.5M"

def test_format_number_billions():
    assert format_number(2_300_000_000) == "2.3B"

def test_format_number_trillions():
    assert format_number(1_200_000_000_000) == "1.2T"

def test_format_number_small():
    assert format_number(500) == "500"

def test_format_number_none():
    assert format_number(None) == "N/A"

def test_enrich_ticker_success():
    mock_info = {
        "shortName": "Apple Inc.",
        "sector": "Technology",
        "currency": "USD",
        "currentPrice": 150.0,
        "marketCap": 2_400_000_000_000,
        "enterpriseValue": 2_500_000_000_000,
        "trailingPE": 25.0,
        "enterpriseToEbitda": 20.0,
        "enterpriseToRevenue": 7.0,
        "freeCashflow": 100_000_000_000,
    }
    with patch("enricher.yf.Ticker") as MockTicker:
        MockTicker.return_value.info = mock_info
        result = enrich_ticker("AAPL")
        assert result["name"] == "Apple Inc."
        assert result["p_fcf"] == 24.0  # 2.4T / 100B

def test_enrich_ticker_not_found():
    with patch("enricher.yf.Ticker") as MockTicker:
        MockTicker.return_value.info = {}
        result = enrich_ticker("FAKE123")
        assert result is None
```

**Step 2: Run tests to verify they fail**

Run: `pytest tests/test_enricher.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'enricher'`

**Step 3: Implement enricher.py**

```python
# enricher.py
import yfinance as yf


def format_number(n) -> str:
    if n is None:
        return "N/A"
    if not isinstance(n, (int, float)):
        return "N/A"
    abs_n = abs(n)
    if abs_n >= 1_000_000_000_000:
        return f"{n / 1_000_000_000_000:.1f}T"
    if abs_n >= 1_000_000_000:
        return f"{n / 1_000_000_000:.1f}B"
    if abs_n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    return f"{n:,.0f}" if isinstance(n, (int, float)) and abs_n >= 1 else str(n)


def enrich_ticker(symbol: str) -> dict | None:
    try:
        t = yf.Ticker(symbol)
        info = t.info
    except Exception:
        return None

    name = info.get("shortName")
    if not name:
        return None

    mcap = info.get("marketCap")
    fcf = info.get("freeCashflow")
    p_fcf = None
    if mcap and fcf and fcf > 0:
        p_fcf = round(mcap / fcf, 1)

    return {
        "symbol": symbol,
        "name": name,
        "sector": info.get("sector", "N/A"),
        "currency": info.get("currency", "N/A"),
        "price": info.get("currentPrice"),
        "market_cap": info.get("marketCap"),
        "enterprise_value": info.get("enterpriseValue"),
        "pe": info.get("trailingPE"),
        "ev_ebitda": info.get("enterpriseToEbitda"),
        "ev_revenue": info.get("enterpriseToRevenue"),
        "p_fcf": p_fcf,
    }
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_enricher.py -v`
Expected: 7 passed

**Step 5: Commit**

```bash
git add enricher.py tests/test_enricher.py
git commit -m "feat: add yfinance ticker enrichment"
```

---

### Task 7: Telegram Formatter (formatter.py)

**Files:**
- Create: `tests/test_formatter.py`
- Create: `formatter.py`

**Step 1: Write failing tests**

```python
# tests/test_formatter.py
import pytest
from formatter import format_message, format_ticker_card, split_message

def test_format_ticker_card():
    ticker = {
        "symbol": "AAPL",
        "name": "Apple Inc.",
        "sector": "Technology",
        "currency": "USD",
        "price": 150.0,
        "market_cap": 2_400_000_000_000,
        "enterprise_value": 2_500_000_000_000,
        "pe": 25.0,
        "ev_ebitda": 20.0,
        "ev_revenue": 7.0,
        "p_fcf": 24.0,
    }
    card = format_ticker_card(ticker)
    assert "AAPL" in card
    assert "Apple Inc." in card
    assert "2.4T" in card

def test_format_message_has_all_sections():
    summary = {
        "tldr": "This is the summary.",
        "key_arguments": ["Arg 1"],
        "key_data_points": ["Data 1"],
        "actionable_takeaways": ["Action 1"],
    }
    msg = format_message(
        pub_name="Test Pub",
        title="Test Article",
        date="2026-03-05",
        url="https://example.com/p/test",
        summary=summary,
        ticker_cards=[],
    )
    assert "Test Pub" in msg
    assert "Test Article" in msg
    assert "This is the summary." in msg
    assert "https://example.com/p/test" in msg

def test_split_message_short():
    msg = "Short message"
    parts = split_message(msg)
    assert len(parts) == 1
    assert parts[0] == msg

def test_split_message_long():
    # Create message longer than 4096
    msg = "Section 1\n\n" + "x" * 2000 + "\n\n---\n\nSection 2\n\n" + "y" * 2000
    parts = split_message(msg, max_len=4096)
    assert len(parts) >= 2
    for part in parts:
        assert len(part) <= 4096
```

**Step 2: Run tests to verify they fail**

Run: `pytest tests/test_formatter.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'formatter'`

**Step 3: Implement formatter.py**

```python
# formatter.py
from enricher import format_number


def format_ticker_card(ticker: dict) -> str:
    lines = [
        f"${ticker['symbol']} - {ticker['name']}",
        f"{ticker['sector']} | {ticker['currency']}",
        f"Price: {ticker['price']} | MCap: {format_number(ticker['market_cap'])} | EV: {format_number(ticker['enterprise_value'])}",
    ]
    multiples = []
    if ticker.get("ev_ebitda"):
        multiples.append(f"EV/EBITDA: {ticker['ev_ebitda']:.1f}")
    if ticker.get("ev_revenue"):
        multiples.append(f"EV/Rev: {ticker['ev_revenue']:.1f}")
    if ticker.get("pe"):
        multiples.append(f"P/E: {ticker['pe']:.1f}")
    if ticker.get("p_fcf"):
        multiples.append(f"P/FCF: {ticker['p_fcf']:.1f}")
    if multiples:
        lines.append(" | ".join(multiples))
    return "\n".join(lines)


def format_message(
    pub_name: str,
    title: str,
    date: str,
    url: str,
    summary: dict,
    ticker_cards: list[str],
    valuation_comment: str = "",
) -> str:
    parts = []

    # Header
    parts.append(f"[ {pub_name} ]\n{title}\n{date}")

    # Summary
    parts.append(f"TL;DR\n{summary['tldr']}")

    if summary.get("key_arguments"):
        args = "\n".join(f"- {a}" for a in summary["key_arguments"])
        parts.append(f"Key Arguments\n{args}")

    if summary.get("key_data_points"):
        data = "\n".join(f"- {d}" for d in summary["key_data_points"])
        parts.append(f"Key Data\n{data}")

    if summary.get("actionable_takeaways"):
        actions = "\n".join(f"- {a}" for a in summary["actionable_takeaways"])
        parts.append(f"Takeaways\n{actions}")

    # Ticker cards
    if ticker_cards:
        parts.append("---")
        for card in ticker_cards:
            parts.append(card)

    # Valuation commentary
    if valuation_comment:
        parts.append(f"---\nValuation Notes\n{valuation_comment}")

    # Link
    parts.append(f"---\nRead full article:\n{url}")

    return "\n\n".join(parts)


def split_message(msg: str, max_len: int = 4096) -> list[str]:
    if len(msg) <= max_len:
        return [msg]
    # Split on section breaks (double newline with ---)
    sections = msg.split("\n\n---\n\n")
    messages = []
    current = ""
    for section in sections:
        candidate = current + ("\n\n---\n\n" if current else "") + section
        if len(candidate) <= max_len:
            current = candidate
        else:
            if current:
                messages.append(current)
            # If single section exceeds max, split on double newline
            if len(section) > max_len:
                lines = section.split("\n\n")
                current = ""
                for line in lines:
                    candidate = current + ("\n\n" if current else "") + line
                    if len(candidate) <= max_len:
                        current = candidate
                    else:
                        if current:
                            messages.append(current)
                        current = line[:max_len]
            else:
                current = section
    if current:
        messages.append(current)
    return messages
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_formatter.py -v`
Expected: 4 passed

**Step 5: Commit**

```bash
git add formatter.py tests/test_formatter.py
git commit -m "feat: add Telegram message formatter with splitting"
```

---

### Task 8: Telegram Sender (sender.py)

**Files:**
- Create: `tests/test_sender.py`
- Create: `sender.py`

**Step 1: Write failing tests**

```python
# tests/test_sender.py
import pytest
from unittest.mock import patch, AsyncMock, MagicMock
from sender import send_message, send_alert

@pytest.mark.asyncio
async def test_send_message_single():
    with patch("sender.Bot") as MockBot:
        bot = MockBot.return_value
        bot.send_message = AsyncMock()
        await send_message("token", "chatid", "Hello")
        bot.send_message.assert_called_once()

@pytest.mark.asyncio
async def test_send_message_split():
    with patch("sender.Bot") as MockBot:
        bot = MockBot.return_value
        bot.send_message = AsyncMock()
        long_msg = "A" * 5000
        await send_message("token", "chatid", long_msg)
        assert bot.send_message.call_count >= 2
```

**Step 2: Run tests to verify they fail**

Run: `pip install pytest-asyncio && pytest tests/test_sender.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'sender'`

**Step 3: Implement sender.py**

```python
# sender.py
from telegram import Bot
from formatter import split_message


async def send_message(bot_token: str, chat_id: str, text: str):
    bot = Bot(token=bot_token)
    parts = split_message(text)
    for part in parts:
        await bot.send_message(chat_id=chat_id, text=part)


async def send_alert(bot_token: str, chat_id: str, alert: str):
    bot = Bot(token=bot_token)
    await bot.send_message(chat_id=chat_id, text=f"[ALERT] {alert}")
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/test_sender.py -v`
Expected: 2 passed

**Step 5: Commit**

```bash
git add sender.py tests/test_sender.py
git commit -m "feat: add Telegram message sender"
```

---

### Task 9: Pipeline Orchestration (main.py)

**Files:**
- Create: `main.py`

**Step 1: Implement main.py**

```python
# main.py
import asyncio
import logging
import os
import yaml
from apscheduler.schedulers.blocking import BlockingScheduler

from db import ArticleDB
from poller import parse_feed
from fetcher import fetch_article
from summarizer import summarize_article
from enricher import enrich_ticker
from formatter import format_message, format_ticker_card
from sender import send_message, send_alert

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger(__name__)


def load_config(path: str = "config.yaml") -> dict:
    with open(path) as f:
        return yaml.safe_load(f)


def process_article(pub: dict, slug: str, url: str, config: dict, db: ArticleDB):
    auth = config["auth"]
    log.info(f"Fetching: {pub['name']} / {slug}")

    # Fetch full article
    article = fetch_article(pub["api_base"], slug, auth, pub)
    if article is None:
        log.warning(f"Failed to fetch {url}")
        return

    # Check cookie health
    if not article["cookie_ok"]:
        log.warning(f"Cookie may be expired for {pub['name']}")
        asyncio.run(send_alert(
            config["telegram"]["bot_token"],
            config["telegram"]["chat_id"],
            f"Cookie expired for {pub['name']}. Got {article['fetched_wordcount']}/{article['wordcount']} words.",
        ))
        return

    # Summarize
    log.info(f"Summarizing: {article['title']}")
    model = config.get("claude", {}).get("model", "sonnet")
    summary = summarize_article(article["body_markdown"], model)
    if summary is None:
        log.warning(f"Failed to summarize {url}")
        return

    # Enrich tickers
    ticker_cards = []
    tickers_data = []
    for ticker_info in summary.get("tickers", []):
        symbol = ticker_info["symbol"]
        log.info(f"Enriching ticker: {symbol}")
        data = enrich_ticker(symbol)
        if data:
            tickers_data.append(data)
            ticker_cards.append(format_ticker_card(data))
        else:
            ticker_cards.append(f"${symbol} - data not available")

    # Get valuation commentary from Claude if we have tickers
    valuation_comment = ""
    if tickers_data:
        from summarizer import get_valuation_comment
        valuation_comment = get_valuation_comment(tickers_data, model) or ""

    # Format message
    msg = format_message(
        pub_name=pub["name"],
        title=article["title"],
        date=article["date"][:10] if article["date"] else "",
        url=url,
        summary=summary,
        ticker_cards=ticker_cards,
        valuation_comment=valuation_comment,
    )

    # Send via Telegram
    log.info(f"Sending to Telegram: {article['title']}")
    asyncio.run(send_message(
        config["telegram"]["bot_token"],
        config["telegram"]["chat_id"],
        msg,
    ))

    # Mark as seen
    db.mark_seen(url, article["title"], pub["name"])
    log.info(f"Done: {article['title']}")


def poll_all(config: dict, db: ArticleDB):
    log.info("Polling all publications...")
    for pub in config["publications"]:
        try:
            articles = parse_feed(pub["feed_url"])
            for article in articles:
                if not db.is_seen(article["url"]):
                    try:
                        process_article(pub, article["slug"], article["url"], config, db)
                    except Exception as e:
                        log.error(f"Error processing {article['url']}: {e}")
        except Exception as e:
            log.error(f"Error polling {pub['name']}: {e}")
    log.info("Polling complete.")


def main():
    config = load_config()
    os.makedirs("data", exist_ok=True)
    db = ArticleDB("data/articles.db")

    interval = config.get("polling", {}).get("interval_minutes", 15)
    log.info(f"Starting SubstackAuto. Polling every {interval} minutes.")

    # Run once immediately
    poll_all(config, db)

    # Schedule recurring
    scheduler = BlockingScheduler()
    scheduler.add_job(poll_all, "interval", minutes=interval, args=[config, db])
    try:
        scheduler.start()
    except KeyboardInterrupt:
        log.info("Shutting down.")


if __name__ == "__main__":
    main()
```

**Step 2: Add get_valuation_comment to summarizer.py**

Append to `summarizer.py`:

```python
def get_valuation_comment(tickers_data: list[dict], model: str = "sonnet") -> str | None:
    from enricher import format_number

    lines = []
    for t in tickers_data:
        lines.append(
            f"{t['symbol']} ({t['name']}): "
            f"P/E={t.get('pe', 'N/A')}, "
            f"EV/EBITDA={t.get('ev_ebitda', 'N/A')}, "
            f"EV/Rev={t.get('ev_revenue', 'N/A')}, "
            f"P/FCF={t.get('p_fcf', 'N/A')}, "
            f"Sector={t.get('sector', 'N/A')}"
        )
    ticker_summary = "\n".join(lines)

    prompt = f"""Given these stock valuation multiples, provide a brief 1-2 sentence comment per ticker on whether the valuation looks cheap, fair, or expensive relative to sector norms. Be concise. No headers or formatting, just one line per ticker.

{ticker_summary}"""

    try:
        result = subprocess.run(
            ["claude", "--print", "--model", model, "-p", prompt],
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None
```

**Step 3: Run the full app manually to verify**

Run: `python main.py`
Expected: Polls feeds, processes new articles, sends Telegram messages. Ctrl+C to stop.

**Step 4: Commit**

```bash
git add main.py summarizer.py
git commit -m "feat: add main pipeline orchestration with scheduler"
```

---

### Task 10: Integration Test

**Files:**
- Create: `tests/test_integration.py`

**Step 1: Write integration test**

```python
# tests/test_integration.py
"""
Integration test: requires network access and valid config.yaml.
Run manually: pytest tests/test_integration.py -v -s
"""
import os
import pytest
from db import ArticleDB
from poller import parse_feed, extract_slug
from fetcher import fetch_article, extract_text

SKIP_INTEGRATION = not os.path.exists("config.yaml")

@pytest.mark.skipif(SKIP_INTEGRATION, reason="No config.yaml")
class TestIntegration:
    @pytest.fixture(autouse=True)
    def setup(self):
        import yaml
        with open("config.yaml") as f:
            self.config = yaml.safe_load(f)

    def test_poll_feed(self):
        pub = self.config["publications"][0]
        articles = parse_feed(pub["feed_url"])
        assert len(articles) > 0
        assert "title" in articles[0]
        assert "slug" in articles[0]

    def test_fetch_article_with_auth(self):
        pub = self.config["publications"][0]
        articles = parse_feed(pub["feed_url"])
        slug = articles[0]["slug"]
        article = fetch_article(
            pub["api_base"], slug, self.config["auth"], pub
        )
        assert article is not None
        assert article["fetched_wordcount"] > 100
        assert len(article["body_markdown"]) > 500
```

**Step 2: Run integration test**

Run: `pytest tests/test_integration.py -v -s`
Expected: 2 passed (if config.yaml exists with valid cookies)

**Step 3: Commit**

```bash
git add tests/test_integration.py
git commit -m "test: add integration tests for feed polling and article fetching"
```

---

### Task 11: Deployment Config

**Files:**
- Create: `substackauto.service`

**Step 1: Create systemd service file**

```ini
# substackauto.service
# Copy to /etc/systemd/system/substackauto.service on VPS
[Unit]
Description=SubstackAuto - Substack article monitor and summarizer
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/substackauto
ExecStart=/home/deploy/substackauto/.venv/bin/python main.py
Restart=always
RestartSec=60
Environment=PATH=/home/deploy/.local/bin:/usr/local/bin:/usr/bin

[Install]
WantedBy=multi-user.target
```

**Step 2: Commit**

```bash
git add substackauto.service
git commit -m "feat: add systemd service for VPS deployment"
```

---

## Task Dependency Graph

```
Task 1 (setup)
  |
  +-> Task 2 (db) ----+
  |                    |
  +-> Task 3 (poller) -+
  |                    |
  +-> Task 4 (fetcher)-+-> Task 9 (main) -> Task 10 (integration)
  |                    |
  +-> Task 5 (summarizer)+
  |                    |
  +-> Task 6 (enricher)+
  |                    |
  +-> Task 7 (formatter)+
  |                    |
  +-> Task 8 (sender) -+
  |
  Task 11 (deployment) -- independent
```

Tasks 2-8 can be implemented in parallel. Task 9 depends on all of them. Task 10 depends on Task 9. Task 11 is independent.
