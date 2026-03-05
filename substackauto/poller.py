# poller.py
from urllib.parse import urlparse
import feedparser


def extract_slug(url: str) -> str:
    path = urlparse(url).path
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
