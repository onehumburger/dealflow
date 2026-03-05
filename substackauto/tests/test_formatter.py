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
    msg = "Section 1\n\n" + "x" * 3000 + "\n\n---\n\nSection 2\n\n" + "y" * 3000
    parts = split_message(msg, max_len=4096)
    assert len(parts) >= 2
    for part in parts:
        assert len(part) <= 4096
