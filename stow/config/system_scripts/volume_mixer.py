#!/usr/bin/env python3
import json
import os
import subprocess
import sys

STEP = "5%"


def build_menu():
    # Call pactl and parse JSON
    proc = subprocess.run(
        ["pactl", "--format", "json", "list", "sink-inputs"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    sinks = json.loads(proc.stdout)
    entries = []
    for sink in sinks:
        idx = sink["index"]
        name = sink.get("properties", {}).get("application.name", "unknown")
        vol = sink["volume"]["front-left"]["value_percent"]
        if name.lower() == "chromium" and "youtube" in sink.get("properties", {}).get(
            "application.process.binary", ""
        ):
            name = "Youtube Music"
        if name.lower() != "unknown" and name not in [e["name"] for e in entries]:
            entries.append({"id": idx, "name": name, "volume": vol})
    return entries


def print_menu(entries):
    for i, entry in enumerate(entries):
        text = f"{entry['name'].title()}: {entry['volume']}"

        print(text)


def get_selected_id(entries) -> int:
    if len(sys.argv) != 2:
        return -1

    sel = sys.argv[1].split(":")[0].lower()
    for i, entry in enumerate(entries):
        if sel == entry["name"].lower():
            return i

    return -1


def main():
    # Set rofi options
    print("\0use-hot-keys\x1ftrue")
    print("\0keep-selection\x1ftrue")
    print("\0keep-filter\x1ftrue")

    entries = build_menu()

    # Get Rofi return code and selection index
    ret = int(os.environ.get("ROFI_RETV", "0"))
    sel = get_selected_id(entries)

    # print(entries)
    # print("SEL" + str(sel))

    if ret in (10, 11):
        # Extract the sink-input index from the selected entry

        idx = str(entries[sel]["id"])

        # Decie whether to raise or lower volume
        change = f"{'-' if ret == 10 else '+'}{STEP}"
        subprocess.run(["pactl", "set-sink-input-volume", idx, change], check=True)

        # Reprint updated menu
        entries = build_menu()
        print_menu(entries)

    else:
        print_menu(entries)


if __name__ == "__main__":
    sys.exit(main())
