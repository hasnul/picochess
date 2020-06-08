import sys
sys.path.append('picochess')
import pytest

from uci import engine

def test_ucishell():
    u = engine.UciShell()
    assert isinstance(u, engine.UciShell)
    assert u.shell is None
    assert u.get() is None

def test_uciengine_init(sf_x86_64):
    assert isinstance(sf_x86_64, engine.UciEngine)
