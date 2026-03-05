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
        assert result["p_fcf"] == 24.0

def test_enrich_ticker_not_found():
    with patch("enricher.yf.Ticker") as MockTicker:
        MockTicker.return_value.info = {}
        result = enrich_ticker("FAKE123")
        assert result is None
