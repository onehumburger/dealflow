# enricher.py
import yfinance as yf


def format_number(n) -> str:
    if n is None:
        return "N/A"
    if not isinstance(n, (int, float)):
        return "N/A"
    abs_n = abs(n)
    if abs_n >= 1_000_000_000_000:
        return f"{n / 1_000_000_000_000:.1f}T"
    if abs_n >= 1_000_000_000:
        return f"{n / 1_000_000_000:.1f}B"
    if abs_n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    return f"{n:,.0f}" if isinstance(n, (int, float)) and abs_n >= 1 else str(n)


def enrich_ticker(symbol: str) -> dict | None:
    try:
        t = yf.Ticker(symbol)
        info = t.info
    except Exception:
        return None

    name = info.get("shortName")
    if not name:
        return None

    mcap = info.get("marketCap")
    fcf = info.get("freeCashflow")
    p_fcf = None
    if mcap and fcf and fcf > 0:
        p_fcf = round(mcap / fcf, 1)

    return {
        "symbol": symbol,
        "name": name,
        "sector": info.get("sector", "N/A"),
        "currency": info.get("currency", "N/A"),
        "price": info.get("currentPrice"),
        "market_cap": info.get("marketCap"),
        "enterprise_value": info.get("enterpriseValue"),
        "pe": info.get("trailingPE"),
        "ev_ebitda": info.get("enterpriseToEbitda"),
        "ev_revenue": info.get("enterpriseToRevenue"),
        "p_fcf": p_fcf,
    }
