# db.py
import sqlite3
from datetime import datetime, timezone


class ArticleDB:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)
        self.conn.execute(
            "CREATE TABLE IF NOT EXISTS articles ("
            "  id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  url TEXT UNIQUE NOT NULL,"
            "  title TEXT,"
            "  pub_name TEXT,"
            "  processed_at TEXT"
            ")"
        )
        self.conn.commit()

    def is_seen(self, url: str) -> bool:
        row = self.conn.execute(
            "SELECT 1 FROM articles WHERE url = ?", (url,)
        ).fetchone()
        return row is not None

    def mark_seen(self, url: str, title: str, pub_name: str):
        self.conn.execute(
            "INSERT OR IGNORE INTO articles (url, title, pub_name, processed_at) "
            "VALUES (?, ?, ?, ?)",
            (url, title, pub_name, datetime.now(timezone.utc).isoformat()),
        )
        self.conn.commit()
