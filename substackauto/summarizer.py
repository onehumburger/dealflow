# summarizer.py
import json
import os
import re
import subprocess


def _clean_env() -> dict:
    """Strip CLAUDECODE env var to allow running inside a Claude Code session."""
    env = os.environ.copy()
    env.pop("CLAUDECODE", None)
    return env


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

IMPORTANT: Only include tickers where the article provides substantive analysis, investment thesis, or financial data about that specific company. Do NOT include tickers that are:
- Used as a passing example or analogy (e.g. "companies like Coca-Cola")
- Mentioned only in a link to another article
- Used to illustrate a general concept without deep analysis
- Mentioned in a sponsorship or advertisement

If the article is a general/educational piece with no deep-dive on any specific stock, return an empty tickers list.

Article:
{article_markdown}"""


def parse_response(response: str) -> dict | None:
    try:
        return json.loads(response)
    except json.JSONDecodeError:
        pass
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
            env=_clean_env(),
        )
        if result.returncode != 0:
            return None
        return parse_response(result.stdout)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


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
            env=_clean_env(),
        )
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None
