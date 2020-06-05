#!/usr/bin/python3

import listengines
import sqlite3
import json

try:
    engine_db = sqlite3.connect(':memory:')
    #logging.debug('Engine database created in memory')
    engine_cur = engine_db.cursor()
    engine_cur.execute('''CREATE TABLE engines
        (id integer PRIMARY KEY,
        name text,
        levels text,
        elo integer,
        chess960 integer,
        comments text,
        location text,
        filetype text,
        command text
        )''')
    engine_db.commit()

    engines = listengines.get_engines('engines/armv7l-pico')
    engjson = json.loads(engines)
    print(type(engjson['data'][0]))
    for line in engjson['data']:
        line[3] = 1 if line[3] == 'y' else 0
        line[2] = int(line[2])
        insert_engine = '''INSERT INTO engines 
            (name, levels, elo, chess960, comments, location, filetype, command)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)'''
        engine_cur.execute(insert_engine, line)
        engine_db.commit()

except sqlite3.Error as error:
    print("%s" % error)
finally:
    engine_cur.execute('SELECT COUNT(*) FROM engines')
    engine_count = engine_cur.fetchall()
    print(f"Found {engine_count[0][0]} engines.")
    engine_cur.execute('SELECT * FROM engines')
    engine_table = engine_cur.fetchall()
    for row in engine_table:
        print(row)
    engine_cur.execute("SELECT name FROM PRAGMA_TABLE_INFO('engines')")
    columns = engine_cur.fetchall()
    for c in columns:
        print(c[0])
    print(columns[1][0])
    engine_db.close()

