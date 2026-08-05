#!/usr/bin/env python3
"""
build_bible_db.py

Converts a full Bible JSON export into a SQLite database compatible
with the GraceLog / SermonKit offline architecture.

Usage:
    python tools/build_bible_db.py --input bible.json --output bible.db

Input JSON schema (expected):
    [
      {
        "book": "Genesis",
        "book_id": "GEN",
        "chapter": 1,
        "verse": 1,
        "text": "In the beginning God created the heaven and the earth."
      },
      ...
    ]

Output SQLite schema:
    books       — canonical book metadata
    chapters    — chapter boundaries per book
    verses      — individual verses with full text
    cross_refs  — (optional) cross-reference index

The output database is designed to be bundled as a Flutter asset
or downloaded as an in-app expansion pack for SermonKit.
"""

import argparse
import json
import sqlite3
import sys
from pathlib import Path
from typing import Any


def create_schema(conn: sqlite3.Connection) -> None:
    """Creates the Bible database schema."""
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS books (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT NOT NULL,
            book_id     TEXT NOT NULL UNIQUE,
            testament   TEXT NOT NULL CHECK(testament IN ('OT', 'NT')),
            position    INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS chapters (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id     TEXT NOT NULL REFERENCES books(book_id),
            chapter     INTEGER NOT NULL,
            verse_count INTEGER NOT NULL DEFAULT 0,
            UNIQUE(book_id, chapter)
        );

        CREATE TABLE IF NOT EXISTS verses (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id     TEXT NOT NULL REFERENCES books(book_id),
            chapter     INTEGER NOT NULL,
            verse       INTEGER NOT NULL,
            text        TEXT NOT NULL,
            UNIQUE(book_id, chapter, verse)
        );

        CREATE INDEX IF NOT EXISTS idx_verses_lookup
            ON verses(book_id, chapter, verse);

        CREATE INDEX IF NOT EXISTS idx_verses_text
            ON verses(text);
    """)
    conn.commit()


def load_bible_json(path: Path) -> list[dict[str, Any]]:
    """Loads and validates the input Bible JSON."""
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        raise ValueError("Input JSON must be a list of verse objects.")

    required_keys = {"book", "book_id", "chapter", "verse", "text"}
    for i, record in enumerate(data[:5], start=1):
        missing = required_keys - set(record.keys())
        if missing:
            raise ValueError(
                f"Record {i} is missing required keys: {missing}"
            )

    return data


def build_database(input_path: Path, output_path: Path) -> None:
    """Main conversion pipeline."""
    print(f"Loading Bible data from {input_path} ...")
    verses = load_bible_json(input_path)
    print(f"Loaded {len(verses):,} verses.")

    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Remove existing database to avoid schema conflicts
    if output_path.exists():
        output_path.unlink()
        print(f"Removed existing database: {output_path}")

    conn = sqlite3.connect(output_path)
    conn.execute("PRAGMA journal_mode = WAL;")
    conn.execute("PRAGMA synchronous = NORMAL;")

    create_schema(conn)

    # ------------------------------------------------------------------
    # 1. Extract unique books with canonical ordering
    # ------------------------------------------------------------------
    book_order: dict[str, int] = {}
    book_testament: dict[str, str] = {}
    book_names: dict[str, str] = {}

    # Standard 66-book KJV canonical order
    CANONICAL_ORDER = [
        # Old Testament
        "GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA",
        "1KI", "2KI", "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO",
        "ECC", "SOS", "ISA", "JER", "LAM", "EZE", "DAN", "HOS", "JOE", "AMO",
        "OBA", "JON", "MIC", "NAH", "HAB", "ZEP", "HAG", "ZEC", "MAL",
        # New Testament
        "MAT", "MAR", "LUK", "JOH", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH",
        "PHI", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAM",
        "1PE", "2PE", "1JO", "2JO", "3JO", "JUD", "REV",
    ]

    for idx, book_id in enumerate(CANONICAL_ORDER, start=1):
        book_order[book_id] = idx
        book_testament[book_id] = "OT" if idx <= 39 else "NT"

    # ------------------------------------------------------------------
    # 2. Populate books table
    # ------------------------------------------------------------------
    seen_books: set[str] = set()
    for v in verses:
        book_id = v["book_id"].upper()
        if book_id not in seen_books:
            seen_books.add(book_id)
            book_names[book_id] = v["book"]
            if book_id not in book_order:
                # Fallback for non-canonical / apocryphal books
                book_order[book_id] = len(book_order) + 1
                book_testament[book_id] = "OT"

    book_rows = [
        (book_names[bid], bid, book_testament[bid], book_order[bid])
        for bid in sorted(seen_books, key=lambda b: book_order[b])
    ]
    conn.executemany(
        "INSERT INTO books (name, book_id, testament, position) VALUES (?, ?, ?, ?)",
        book_rows,
    )
    conn.commit()
    print(f"Inserted {len(book_rows)} books.")

    # ------------------------------------------------------------------
    # 3. Populate verses and chapters
    # ------------------------------------------------------------------
    verse_rows = []
    chapter_counts: dict[tuple[str, int], int] = {}

    for v in verses:
        book_id = v["book_id"].upper()
        chapter = int(v["chapter"])
        verse_num = int(v["verse"])
        text = v["text"].strip()

        verse_rows.append((book_id, chapter, verse_num, text))
        chapter_counts[(book_id, chapter)] = chapter_counts.get((book_id, chapter), 0) + 1

    conn.executemany(
        "INSERT INTO verses (book_id, chapter, verse, text) VALUES (?, ?, ?, ?)",
        verse_rows,
    )
    conn.commit()
    print(f"Inserted {len(verse_rows):,} verses.")

    # ------------------------------------------------------------------
    # 4. Populate chapters with computed verse counts
    # ------------------------------------------------------------------
    chapter_rows = [
        (bid, ch, count)
        for (bid, ch), count in sorted(chapter_counts.items())
    ]
    conn.executemany(
        "INSERT INTO chapters (book_id, chapter, verse_count) VALUES (?, ?, ?)",
        chapter_rows,
    )
    conn.commit()
    print(f"Inserted {len(chapter_rows)} chapters.")

    # ------------------------------------------------------------------
    # 5. Validate and optimize
    # ------------------------------------------------------------------
    cursor = conn.execute("SELECT COUNT(*) FROM verses")
    total_verses = cursor.fetchone()[0]
    cursor = conn.execute("SELECT COUNT(DISTINCT book_id) FROM verses")
    total_books = cursor.fetchone()[0]
    cursor = conn.execute("SELECT COUNT(*) FROM chapters")
    total_chapters = cursor.fetchone()[0]

    conn.execute("VACUUM;")
    conn.execute("PRAGMA optimize;")
    conn.close()

    print("\nBuild complete.")
    print(f"  Output:   {output_path}")
    print(f"  Books:    {total_books}")
    print(f"  Chapters: {total_chapters}")
    print(f"  Verses:   {total_verses:,}")
    print(f"  Size:     {output_path.stat().st_size:,} bytes")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert Bible JSON to SQLite for GraceLog / SermonKit."
    )
    parser.add_argument(
        "--input", "-i",
        type=Path,
        required=True,
        help="Path to input Bible JSON file.",
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        required=True,
        help="Path to output SQLite database file.",
    )
    args = parser.parse_args()

    if not args.input.exists():
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        return 1

    try:
        build_database(args.input, args.output)
        return 0
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
