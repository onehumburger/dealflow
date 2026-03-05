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
        long_msg = "A" * 5000
        await send_message("token", "chatid", long_msg)
        assert bot.send_message.call_count >= 2
