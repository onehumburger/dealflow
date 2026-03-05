# fetcher.py
from urllib.parse import urlparse
import httpx
import html2text

_h2t = html2text.HTML2Text()
_h2t.ignore_links = False
_h2t.ignore_images = True
_h2t.body_width = 0

USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
)


def get_cookie_header(auth: dict, pub: dict) -> str:
    if pub["cookie_type"] == "substack.sid":
        return f"substack.sid={auth['substack_sid']}"
    domain = urlparse(pub["api_base"]).hostname
    connect_sid = auth["connect_sids"].get(domain, "")
    parts = [f"connect.sid={connect_sid}"]
    if auth.get("substack_sid"):
        parts.append(f"substack.sid={auth['substack_sid']}")
    return "; ".join(parts)


def extract_text(body_html: str) -> str:
    return _h2t.handle(body_html)


def fetch_article(api_base: str, slug: str, auth: dict, pub: dict) -> dict | None:
    url = f"{api_base}/api/v1/posts/{slug}"
    cookie = get_cookie_header(auth, pub)
    resp = httpx.get(
        url,
        headers={"Cookie": cookie, "User-Agent": USER_AGENT},
        timeout=30,
    )
    if resp.status_code != 200:
        return None
    data = resp.json()
    body_html = data.get("body_html", "")
    text = extract_text(body_html)
    word_count = len(text.split())
    expected_wc = data.get("wordcount", 0)
    return {
        "title": data.get("title", ""),
        "subtitle": data.get("description", ""),
        "date": data.get("post_date", ""),
        "audience": data.get("audience", "everyone"),
        "wordcount": expected_wc,
        "fetched_wordcount": word_count,
        "body_markdown": text,
        "cookie_ok": word_count >= expected_wc * 0.8 if expected_wc > 0 else True,
    }
