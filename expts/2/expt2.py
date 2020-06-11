import asyncio
from asyncssh import connect
import chess
import chess.engine
import dotenv
import logging
import os

MAX_PLIES = 160
MAX_TIME = 0.1
PROTOCOL = chess.engine.UciProtocol
#PROTOCOL = chess.engine.XBoardProtocol

logging.basicConfig(filename='anmon.log', level=logging.DEBUG)
home = os.environ.get('HOME')
dotenv.load_dotenv(home + os.sep + '.chess_engine_server.env')

hostname = os.environ.get('CHESS_ENGINE_SERVER') 
user = os.environ.get('CHESS_ENGINE_SERVER_USER')
password = os.environ.get('CHESS_ENGINE_SERVER_PASSWORD')
engine_home = 'C:\\Houdini_15a'
#engine_name = 'Houdini_15a_w32.exe'
engine_name = 'AnMon_5.75.exe'
#engine_name = 'frenzee.exe'
engine_path = engine_home + '\\' + engine_name

async def main():
    async with connect(hostname, username=user, password=password, 
            known_hosts=None) as conn:
        channel, engine = await conn.create_subprocess(PROTOCOL, engine_path)
        await engine.initialize()
        try:
            await engine.configure({'Threads': 1})
        except:
            logging.debug(f'Engine {engine.id["name"]} has no Threads option')
        ply_count = 0
        board = chess.Board()
        while not board.is_game_over() and ply_count < MAX_PLIES:
            result = await engine.play(board, chess.engine.Limit(time=MAX_TIME))
            board.push(result.move)
            ply_count += 1
        await engine.quit()

asyncio.set_event_loop_policy(chess.engine.EventLoopPolicy())
asyncio.run(main())
