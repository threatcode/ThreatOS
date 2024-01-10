#!/usr/bin/env python3
# REF: https://github.com/threatcode/nethunter/build-scripts/threatos-nethunter-devices/-/blob/52cbfb36/scripts/generate_images_stats.py
import sys
from datetime import datetime

import yaml  # python3 -m pip install pyyaml --user

OUTPUT_FILE = "./kernel-stats.md"

INPUT_FILE = "./devices.yml"

repo_msg = f"""
_This table was [generated automatically](https://github.com/threatcode/threatos/-/blob/master/devices.yml) on {datetime.now().strftime('%Y-%B-%d %H:%M:%S')} from the [Threatos ARM GitLab repository](https://github.com/threatcode/threatos)_
"""

qty_kernels = 0
qty_versions = {
    "custom":  0,
    "threatos":    0,
    "vendor":  0
}

# Input:
# ------------------------------------------------------------
# See: ./devices.yml
# https://github.com/threatcode/threatos/-/blob/master/devices.yml


def yaml_parse(content):
    result = ""
    lines = content.split("\n")

    for line in lines:
        if line.strip() and not line.strip().startswith("#"):
            result += line + "\n"

    return yaml.safe_load(result)


def generate_table(data):
    global qty_kernels, qty_versions

    images = []
    default = "unknown"

    # Iterate over per input (depth 1)
    for yaml in data["devices"]:
        # Iterate over vendors
        for vendor in yaml.keys():
            # Iterate over board (depth 2)
            for board in yaml[vendor]:
                # Iterate over per board
                for key in board.keys():
                    # Check if there is an image for the board
                    if "images" in key:
                        # Iterate over image (depth 3)
                        for image in board[key]:
                            if image["name"] not in images:
                                # ALT: images.append(image["image"])
                                images.append(image["name"])

                                qty_kernels += 1
                                qty_versions[(image.get("kernel", default))] += 1

                            # else:
                            #    print(f"DUP {image['name']} / {image['image']}")

                if "images" not in board.keys():
                    print(f"[i] Possible issue with: {board.get('board', default)} (no images)")

    table = "| Kernel | Qty |\n"
    table += "|--------|-----|\n"

    # iterate over all the devices
    for v in qty_versions:
        table += f"| {v.capitalize()} | {qty_versions[v]} |\n"

    return table


def read_file(file):
    try:
        with open(file) as f:
            data = f.read()

    except Exception as e:
        print(f"[-] Cannot open input file: {file} - {e}")

    return data


def write_file(data, file):
    try:
        with open(file, "w") as f:
            meta = "---\n"
            meta += "title: Threatos ARM Kernel Statistics\n"
            meta += "---\n\n"

            stats = f"- The official [Threatos ARM repository](https://github.com/threatcode/threatos) contains [build-scripts]((https://github.com/threatcode/threatos)) to create [**{qty_kernels}** unique Threatos ARM images](images.html)\n"
            stats += "- [Threatos ARM Statistics](index.html)\n\n"

            f.write(str(meta))
            f.write(str(stats))
            f.write(str(data))
            f.write(str(repo_msg))

            print(f"[+] File: {OUTPUT_FILE} successfully written")

    except Exception as e:
        print(f"[-] Cannot write to output file: {file} - {e}")

    return 0


def print_summary():
    print(f"Kernels: {qty_kernels}")


def main(argv):
    # Assign variables
    data = read_file(INPUT_FILE)

    # Get data
    res = yaml_parse(data)
    generated_markdown = generate_table(res)

    # Create markdown file
    write_file(generated_markdown, OUTPUT_FILE)

    # Print result
    print_summary()

    # Exit
    exit(0)


if __name__ == "__main__":
    main(sys.argv[1:])
