#!/usr/bin/python3

import chess.pgn as pgn
import json

def pgn_to_json(pgnfile):
    try:
        games_pgn = open(pgnfile)
        headers = pgn.scan_headers(games_pgn)
    except FileNotFoundError:
        return f"Pgn file {pgnfile} not found"
    json_str = ['{"data":[']
    try:
        header = next(headers)
        while True:
            header_values = list(header[1].values()) 
            json_str.append(json.dumps(header_values))
            header = next(headers)
            json_str.append(',')
    except StopIteration:
        pass
    games_pgn.close()
    json_str.append(']}')
    return "".join(json_str) 

if __name__ == '__main__':
    try:
        jsondata = json.loads(pgn_to_json("games/games.pgn"))
        print("Valid JSON")
        for j in jsondata['data']:
            print(j)
    except ValueError:
        print("Invalid JSON")
        
