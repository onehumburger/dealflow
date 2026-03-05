# tests/test_summarizer.py
import json
import pytest
from unittest.mock import patch, MagicMock
from summarizer import build_prompt, parse_response

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
