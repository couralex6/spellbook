import pytest
from line_mapper import LineMapper


### LineMapper Includes an ASSERT that checks if the lines are the same so tests don't need an assert
### assert compiled_lines == spell_lines, f"Lines don't match:\n{compiled_lines}\n{spell_lines}"
def test_line_mapper1():
    """Test the line mapper."""
    SPELL_PATH = "models/aave/ethereum/aave_ethereum_borrow.sql"
    COMPILED_PATH = f"target/compiled/spellbook/{SPELL_PATH}"
    START = 3
    END = 4
    parser = LineMapper(spell_path=SPELL_PATH, compiled_path=COMPILED_PATH, start=START, end=END)
    parser.main()

def test_line_mapper2():
    """Test the line mapper."""
    SPELL_PATH = "models/nomad/ethereum/nomad_ethereum_view_bridge_transactions.sql"
    COMPILED_PATH = f"target/compiled/spellbook/{SPELL_PATH}"
    START = 5
    END = 6
    parser = LineMapper(spell_path=SPELL_PATH, compiled_path=COMPILED_PATH, start=START, end=END)
    parser.main()

def test_line_mapper3():
    """Test the line mapper."""
    SPELL_PATH = "models/nexusmutual/ethereum/nexusmutual_ethereum_product_information.sql"
    COMPILED_PATH = f"target/compiled/spellbook/{SPELL_PATH}"
    START = 3
    END = 4
    parser = LineMapper(spell_path=SPELL_PATH, compiled_path=COMPILED_PATH, start=START, end=END)
    parser.main()

def test_line_mapper4():
    """Test the line mapper."""
    SPELL_PATH = "models/aave/ethereum/aave_ethereum_votes.sql"
    COMPILED_PATH = f"target/compiled/spellbook/{SPELL_PATH}"
    START = 8
    END = 9
    parser = LineMapper(spell_path=SPELL_PATH, compiled_path=COMPILED_PATH, start=START, end=END)
    parser.main()

test_line_mapper1()
test_line_mapper2()
test_line_mapper3()
test_line_mapper4()