#!/usr/bin/python3

from os import listdir
from os.path import isfile, join
from collections import OrderedDict
import magic
import configparser
import json

ENGINE_INI = 'engines.ini'
def get_engines(folder):
    """
    Return a json of the attributes of engines found in folder.
    Primarily relies on 'engines.ini'. It tries to locate the entry
    found in 'engines.ini' with the contents of the folder.
    Does not look into sub-directories.

    There are eight fields ordered as follows:
      name, levels, elo, fischer, comments, location, filetype, command
    """
    files = [f for f in listdir(folder) if isfile(join(folder, f))]
    json_str = ['{"data":[']
    if ENGINE_INI in files:
        inifile = join(folder, ENGINE_INI)
        config = configparser.ConfigParser()
        config.read(inifile)
        engine_attr = OrderedDict() 
        first = True
        attributes = ['name', 'levels', 'elo', 'fischer chess960 support', 'comments']
        for s in config.sections():
            for attr in attributes:
                engine_attr[attr] = config[s][attr] if attr in config[s] else '' 
            engine_attr['location'] = folder 
            if s in files:
                file_magic = magic.from_file(join(folder, s))
                abbrev = file_magic.split(' ')[0] 
                engine_attr['filetype'] = abbrev if abbrev != 'Bourne-Again' else 'bash'
                engine_attr['command'] = s
            else:
                engine_attr['command'] = 'Not found'
                engine_attr['filetype'] = 'None'
            if first:
                first = False
            else:
                json_str.append(',')
            json_str.append(json.dumps(list(engine_attr.values())))
    json_str.append(']}')
    return "".join(json_str)

if __name__ == '__main__':
    engines = get_engines("engines/armv7l-pico")
    try:
        jsondata = json.loads(engines)
        print("Valid JSON")
        for j in jsondata['data']:
            print(j)
    except ValueError:
        print("Invalid JSON")
