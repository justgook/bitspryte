#!/usr/bin/env python3
"""Regression checks for semantic differences between rGuiLayout and Odin output."""

from pathlib import Path
import subprocess
import tempfile
import unittest


class RglToOdinTests(unittest.TestCase):
    def test_empty_control_text_is_generated_as_nil(self) -> None:
        source = """r 0 0 100 100
c 000 3 emptyPanel 0 0 100 100 0 
c 001 3 titledPanel 0 0 100 100 0 Header
"""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            input_path = root / "layout.rgl"
            output_path = root / "layout.odin"
            input_path.write_text(source)

            subprocess.run(
                ["python3", "tools/rgl_to_odin.py", str(input_path), str(output_path)],
                check=True,
            )
            generated = output_path.read_text()

        self.assertIn('import rl "vendor:raylib"', generated)
        self.assertNotIn('vendor:raylib/v55', generated)
        self.assertIn("emptyPanel_TEXT: cstring", generated)
        self.assertNotIn('emptyPanel_TEXT :: cstring("")', generated)
        self.assertIn('titledPanel_TEXT :: cstring("Header")', generated)


if __name__ == "__main__":
    unittest.main()
