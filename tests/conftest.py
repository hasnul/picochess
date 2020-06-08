import sys
sys.path.append('picochess')
import pathlib
import pytest
from uci import engine

@pytest.fixture
def sf_x86_64():
    """Local stockfish x86-64 arch UCIEngine"""
    sf_file = 'picochess/engines/x86_64/a-stock8'
    assert pathlib.Path(sf_file).is_file()
    sf = engine.UciEngine(sf_file, engine.UciShell())
    return sf
