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
