import pytest
import spur
from uci import engine

def test_ucishell():
    u = engine.UciShell()
    assert type(u) == engine.UciShell
    assert u.shell is None
    assert u.get() is None
