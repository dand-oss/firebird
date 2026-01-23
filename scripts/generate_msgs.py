#!/usr/bin/env python3
"""
Generate msgs.h from messages2.sql

This script parses the Firebird messages2.sql file and generates a complete
msgs.h header file with all messages sorted by code number.

The original codes.epp generator only includes messages that have entries in
SYSTEM_ERRORS, resulting in an incomplete msgs.h that's missing many facilities.
This script extracts all messages directly from messages2.sql.

Usage:
    python generate_msgs.py

Code calculation:
    ISC_MASK = 0x14000000
    code = ISC_MASK | (fac_code << 16) | number
"""

import re
import os
from pathlib import Path

# ISC error mask constant
ISC_MASK = 0x14000000

# Paths relative to script location
SCRIPT_DIR = Path(__file__).parent
REPO_DIR = SCRIPT_DIR.parent
MESSAGES_SQL = REPO_DIR / "src" / "msgs" / "messages2.sql"
MSGS_H = REPO_DIR / "src" / "include" / "gen" / "msgs.h"


def parse_messages(content: str) -> list[tuple[int, str, int, str]]:
    """
    Parse messages2.sql and extract (code, text, number, symbol) tuples.

    The SQL format is:
        (symbol, routine, module, trans_notes, FAC_CODE, NUMBER, flags, 'TEXT', action, explanation);

    Returns list of (code, text, number, symbol) sorted by code.
    """
    messages = []

    # Split content into individual INSERT statements
    # Each statement ends with );
    entries = content.split(');')

    for entry in entries:
        entry = entry.strip()
        if not entry.startswith('('):
            continue

        # Remove the leading (
        entry = entry[1:].strip()

        # Parse the fields - this is tricky because of embedded quotes and commas
        fields = parse_sql_values(entry)

        if len(fields) < 8:
            continue

        # Field indices:
        # 0: symbol, 1: routine, 2: module, 3: trans_notes
        # 4: FAC_CODE, 5: NUMBER, 6: flags, 7: TEXT
        # 8: action, 9: explanation

        symbol = fields[0]
        try:
            fac_code = int(fields[4])
            number = int(fields[5])
        except (ValueError, TypeError):
            continue

        text = fields[7]
        if text is None:
            text = ""

        # Calculate the code number
        code = ISC_MASK | (fac_code << 16) | number

        # Clean up symbol - remove quotes
        if symbol and symbol != 'NULL':
            symbol = symbol.strip("'")
        else:
            symbol = None

        messages.append((code, text, number, symbol))

    # Sort by code number
    messages.sort(key=lambda x: x[0])

    return messages


def parse_sql_values(entry: str) -> list[str | None]:
    """
    Parse SQL VALUES clause into individual field values.

    Handles:
    - NULL values
    - Single-quoted strings with '' escapes
    - Numeric values
    - Multi-line strings
    """
    fields = []
    i = 0
    n = len(entry)

    while i < n:
        # Skip whitespace
        while i < n and entry[i] in ' \t\n\r':
            i += 1

        if i >= n:
            break

        # Check for NULL
        if entry[i:i+4].upper() == 'NULL':
            fields.append(None)
            i += 4
        # Check for quoted string
        elif entry[i] == "'":
            # Find the end of the quoted string (handling '' escapes)
            i += 1
            start = i
            value = []
            while i < n:
                if entry[i] == "'" and i + 1 < n and entry[i + 1] == "'":
                    # Escaped quote
                    value.append(entry[start:i + 1])
                    i += 2
                    start = i
                elif entry[i] == "'":
                    # End of string
                    value.append(entry[start:i])
                    i += 1
                    break
                else:
                    i += 1
            else:
                # End of entry without closing quote - take what we have
                value.append(entry[start:])
            fields.append(''.join(value))
        # Check for numeric value
        elif entry[i].isdigit() or (entry[i] == '-' and i + 1 < n and entry[i + 1].isdigit()):
            start = i
            if entry[i] == '-':
                i += 1
            while i < n and entry[i].isdigit():
                i += 1
            fields.append(entry[start:i])
        # Check for +++ (continuation marker used in original file)
        elif entry[i:i+3] == '+++':
            i += 3
            # Skip to next field - this is a formatting artifact
            continue

        # Skip comma and whitespace before next field
        while i < n and entry[i] in ' \t\n\r':
            i += 1
        if i < n and entry[i] == ',':
            i += 1
        elif i < n and entry[i] == ')':
            break

    return fields


def escape_c_string(s: str) -> str:
    """Escape a string for use in C code."""
    result = []
    for c in s:
        if c == '"':
            result.append('\\"')
        elif c == '\\':
            result.append('\\\\')
        elif c == '\n':
            result.append('\\n')
        elif c == '\r':
            result.append('\\r')
        elif c == '\t':
            result.append('\\t')
        else:
            result.append(c)
    return ''.join(result)


def generate_msgs_h(messages: list[tuple[int, str, int, str]]) -> str:
    """Generate the msgs.h header file content."""
    lines = []

    # Header comment
    lines.append("""/*
 * The contents of this file are subject to the Interbase Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy
 * of the License at http://www.Inprise.com/IPL.html
 *
 * Software distributed under the License is distributed on an
 * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The content of this file was generated by scripts/generate_msgs.py
 * from src/msgs/messages2.sql
 */
/*
 *
 * *** WARNING *** - This file is automatically generated - do not edit!
 *
 */
static const struct {
\tSLONG code_number;
\tconst SCHAR *code_text;
} messages[] = {""")

    # Message entries
    for code, text, number, symbol in messages:
        escaped_text = escape_c_string(text)
        comment = f"/* {number}"
        if symbol:
            comment += f", {symbol}"
        comment += " */"
        lines.append(f'\t{{{code}, "{escaped_text}"}},\t\t{comment}')

    # Terminator
    lines.append("\t{0, NULL}")
    lines.append("};")

    return '\n'.join(lines)


def main():
    print(f"Reading {MESSAGES_SQL}...")
    content = MESSAGES_SQL.read_text(encoding='utf-8')

    print("Parsing messages...")
    messages = parse_messages(content)

    # Filter out empty messages at offset 0 (these are just placeholders)
    messages = [(c, t, n, s) for c, t, n, s in messages if t or n > 0]

    print(f"Found {len(messages)} messages")

    # Show facility breakdown
    facilities = {}
    for code, text, number, symbol in messages:
        fac = (code >> 16) & 0xFF
        facilities[fac] = facilities.get(fac, 0) + 1

    print("Messages by facility:")
    for fac in sorted(facilities.keys()):
        print(f"  Facility {fac}: {facilities[fac]} messages")

    print(f"\nGenerating {MSGS_H}...")
    output = generate_msgs_h(messages)

    MSGS_H.write_text(output, encoding='utf-8')
    print(f"Generated {MSGS_H} with {len(messages)} messages")


if __name__ == '__main__':
    main()
