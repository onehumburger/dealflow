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
