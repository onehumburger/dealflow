import pytest
from unittest.mock import patch, AsyncMock, MagicMock
from sender import send_message, send_alert


@pytest.mark.asyncio
async def test_send_message_single():
    with patch("sender.Bot") as MockBot:
        bot = MockBot.return_value
        bot.send_message = AsyncMock()
        await send_message("token", "chatid", "Hello")
        bot.send_message.assert_called_once()


@pytest.mark.asyncio
async def test_send_message_split():
    with patch("sender.Bot") as MockBot:
        bot = MockBot.return_value
        bot.send_message = AsyncMock()
        long_msg = "Section 1\n\n" + "A" * 3000 + "\n\n---\n\nSection 2\n\n" + "B" * 3000
        await send_message("token", "chatid", long_msg)
        assert bot.send_message.call_count >= 2
