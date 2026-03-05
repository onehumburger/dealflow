# sender.py
from telegram import Bot
from formatter import split_message


async def send_message(bot_token: str, chat_id: str, text: str):
    bot = Bot(token=bot_token)
    parts = split_message(text)
    for part in parts:
        await bot.send_message(chat_id=chat_id, text=part)


async def send_alert(bot_token: str, chat_id: str, alert: str):
    bot = Bot(token=bot_token)
    await bot.send_message(chat_id=chat_id, text=f"[ALERT] {alert}")
