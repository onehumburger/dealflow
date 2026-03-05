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
