import sys
sys.path.append('picochess')
import pytest
import uci 

@pytest.fixture
def sf_x86_64():
    """Local stockfish x86-64 arch UCIEngine"""
    sf = uci.engine.UciEngine('engine/x86_64/a-stock8', uci.engine.UciShell())
    return sf
