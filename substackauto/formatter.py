# formatter.py
from enricher import format_number


def format_ticker_card(ticker: dict) -> str:
    lines = [
        f"${ticker['symbol']} - {ticker['name']}",
        f"{ticker['sector']} | {ticker['currency']}",
        f"Price: {ticker['price']} | MCap: {format_number(ticker['market_cap'])} | EV: {format_number(ticker['enterprise_value'])}",
    ]
    multiples = []
    if ticker.get("ev_ebitda"):
        multiples.append(f"EV/EBITDA: {ticker['ev_ebitda']:.1f}")
    if ticker.get("ev_revenue"):
        multiples.append(f"EV/Rev: {ticker['ev_revenue']:.1f}")
    if ticker.get("pe"):
        multiples.append(f"P/E: {ticker['pe']:.1f}")
    if ticker.get("p_fcf"):
        multiples.append(f"P/FCF: {ticker['p_fcf']:.1f}")
    if multiples:
        lines.append(" | ".join(multiples))
    return "\n".join(lines)


def format_message(
    pub_name: str,
    title: str,
    date: str,
    url: str,
    summary: dict,
    ticker_cards: list[str],
    valuation_comment: str = "",
) -> str:
    parts = []
    parts.append(f"[ {pub_name} ]\n{title}\n{date}")
    parts.append(f"TL;DR\n{summary['tldr']}")

    if summary.get("key_arguments"):
        args = "\n".join(f"- {a}" for a in summary["key_arguments"])
        parts.append(f"Key Arguments\n{args}")

    if summary.get("key_data_points"):
        data = "\n".join(f"- {d}" for d in summary["key_data_points"])
        parts.append(f"Key Data\n{data}")

    if summary.get("actionable_takeaways"):
        actions = "\n".join(f"- {a}" for a in summary["actionable_takeaways"])
        parts.append(f"Takeaways\n{actions}")

    if ticker_cards:
        parts.append("---")
        for card in ticker_cards:
            parts.append(card)

    if valuation_comment:
        parts.append(f"---\nValuation Notes\n{valuation_comment}")

    parts.append(f"---\nRead full article:\n{url}")
    return "\n\n".join(parts)


def split_message(msg: str, max_len: int = 4096) -> list[str]:
    if len(msg) <= max_len:
        return [msg]
    sections = msg.split("\n\n---\n\n")
    messages = []
    current = ""
    for section in sections:
        candidate = current + ("\n\n---\n\n" if current else "") + section
        if len(candidate) <= max_len:
            current = candidate
        else:
            if current:
                messages.append(current)
            if len(section) > max_len:
                lines = section.split("\n\n")
                current = ""
                for line in lines:
                    candidate = current + ("\n\n" if current else "") + line
                    if len(candidate) <= max_len:
                        current = candidate
                    else:
                        if current:
                            messages.append(current)
                        current = line[:max_len]
            else:
                current = section
    if current:
        messages.append(current)
    return messages
