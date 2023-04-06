import pytest
from line_mapper import LineMapper

def test_line_mapper():
    """Test the line mapper."""
    SPELL_PATH = "models/aave/ethereum/aave_ethereum_borrow.sql"
    COMPILED_PATH = f"target/compiled/spellbook/{SPELL_PATH}"
    START = 3
    END = 4
    parser = LineMapper(spell_path=SPELL_PATH, compiled_path=COMPILED_PATH, start=START, end=END)
    parser.main()


test_line_mapper()