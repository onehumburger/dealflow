# tests/test_fetcher.py
import pytest
from fetcher import get_cookie_header, extract_text

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
