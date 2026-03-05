"""Telegram message formatting utilities."""

MAX_MESSAGE_LENGTH = 4096


def split_message(text: str, max_length: int = MAX_MESSAGE_LENGTH) -> list[str]:
    """Split a long message into parts that fit Telegram's message size limit."""
    if len(text) <= max_length:
        return [text]
    parts = []
    while text:
        parts.append(text[:max_length])
        text = text[max_length:]
    return parts
