# main.py
import asyncio
import logging
import os
import yaml
from apscheduler.schedulers.blocking import BlockingScheduler

from db import ArticleDB
from poller import parse_feed
from fetcher import fetch_article
from summarizer import summarize_article, get_valuation_comment
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
