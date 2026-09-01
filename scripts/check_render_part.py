#!/usr/bin/env python3
"""Lint phone_holder.scad's render_part Customizer dropdown.

The `render_part = "...";  // [key:label,key:label,...]` line drives the
OpenSCAD Customizer (and the web version of it). Comma is the delimiter
BETWEEN options -- a literal comma inside a label's own text silently
splits it into a bogus extra option and corrupts the dropdown. This has
shipped for real twice (commit 99ffa09, and again 2026-09-01).

Checks:
  1. Every comma-separated segment in the [...] list starts with a bare
     identifier key followed by ':' -- a label-embedded comma produces a
     segment whose "key" is actually a fragment of prose and fails this.
  2. Every key in the dropdown has a matching `render_part == "key"` (or
     `render_part == 'key'`) check in the file, and vice versa -- catches
     an option added without dispatch logic, or dispatch logic for an
     option that's been removed/renamed from the dropdown.

Exits 0 (silent) if clean, 1 with a description of every problem found.
"""
import re
import sys
from pathlib import Path

KEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def find_scad_file(start: Path) -> Path | None:
    for candidate in [start / "phone_holder.scad", *start.rglob("phone_holder.scad")]:
        if candidate.is_file():
            return candidate
    return None


def main() -> int:
    repo_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    scad_path = find_scad_file(repo_root)
    if scad_path is None:
        print(f"check_render_part: no phone_holder.scad found under {repo_root}", file=sys.stderr)
        return 1

    text = scad_path.read_text()
    line_match = re.search(r'^render_part\s*=\s*"[^"]*"\s*;\s*//\s*\[(.*)\]\s*$', text, re.MULTILINE)
    if line_match is None:
        print(f"check_render_part: couldn't find the render_part Customizer comment in {scad_path}", file=sys.stderr)
        return 1

    options_str = line_match.group(1)
    segments = options_str.split(",")

    errors = []
    keys = []
    for i, seg in enumerate(segments):
        key = seg.split(":", 1)[0]
        if not KEY_RE.match(key):
            errors.append(
                f"segment {i + 1}/{len(segments)} has an invalid key {key!r} -- likely a comma "
                f"inside a PREVIOUS label's text splitting it into a bogus extra option.\n"
                f"    segment text: {seg!r}"
            )
        else:
            keys.append(key)

    dispatch_keys = set(re.findall(r'render_part\s*==\s*["\']([A-Za-z_][A-Za-z0-9_]*)["\']', text))
    dropdown_keys = set(keys)

    # The dispatch chain's final `else { ... }` (bare, no condition) is a
    # deliberate catch-all -- by convention the LAST dropdown option (e.g.
    # "full") relies on it instead of its own `render_part == "..."` case.
    has_bare_else = re.search(r"render_part\s*==.*\n(?:.*\n)*?\s*else\s*\{", text) is not None
    exempt = {keys[-1]} if (has_bare_else and keys) else set()

    missing_dispatch = dropdown_keys - dispatch_keys - exempt
    missing_dropdown = dispatch_keys - dropdown_keys
    if missing_dispatch:
        errors.append(f"dropdown option(s) with no `render_part == \"...\"` dispatch case: {sorted(missing_dispatch)}")
    if missing_dropdown:
        errors.append(f"dispatch case(s) for key(s) not in the dropdown list: {sorted(missing_dropdown)}")

    if errors:
        print(f"check_render_part: {scad_path} FAILED:\n", file=sys.stderr)
        for e in errors:
            print(f"  - {e}\n", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
