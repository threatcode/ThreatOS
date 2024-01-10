#!/usr/bin/env python3
# REF: https://github.com/threatcode/nethunter/build-scripts/threatos-nethunter-devices/-/blob/95ad7d2b/scripts/generate_images_table.py
import sys
from datetime import datetime

import yaml  # python3 -m pip install pyyaml --user

OUTPUT_FILE = "./images.md"

INPUT_FILE = "./devices.yml"

repo_msg = f"""
_This table was [generated automatically](https://github.com/threatcode/threatos/-/blob/master/devices.yml) on {datetime.now().strftime('%Y-%B-%d %H:%M:%S')} from the [Threatos ARM GitLab repository](https://github.com/threatcode/threatos)_
"""

qty_devices = 0
qty_images = 0
qty_images_released = 0

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
    global qty_devices, qty_images, qty_images_released

    images = []

    images_released = []

    default = ""

    table = "| Image Name | Filename | Architecture | Preferred | Support | [Documentation](https://threatcode.github.io/docs/arm/) | [Kernel](kernel-stats.html) | Kernel Version | Notes |\n"
    table += "|------------|----------|--------------|-----------|---------|-------------------------------------------------|-----------------------|----------------|-------|\n"

    # Iterate over per input (depth 1)
    for yaml in data["devices"]:
        # Iterate over vendors
        for vendor in yaml.keys():
            # Iterate over board (depth 2)
            for board in yaml[vendor]:
                qty_devices += 1

                # Iterate over per board
                for key in board.keys():
                    # Check if there is an image for the board
                    if "images" in key:
                        # Iterate over image (depth 3)
                        for image in board[key]:
                            #qty_images += 1
                            images.append(f"{image.get('name', default)}")

                            support = image.get("support", default)

                            if support == "threatos":
                                #qty_images_released += 1
                                images_released.append(
                                    f"{image.get('name', default)}")

                            slug = image.get("slug", default)

                            if slug:
                                slug = f"[{slug}](https://threatcode.github.io/docs/arm/{slug}/)"

                            table += f"| {image.get('name', default)} | {image.get('image', default)} | {image.get('architecture', default)} | {image.get('preferred-image', default)} | {image.get('support', default)} | {slug} | {image.get('kernel', default)} | {image.get('kernel-version', default)} | {image.get('image-notes', default)} |\n"

                if "images" not in board.keys():
                    print(
                        f"[i] Possible issue with: {board.get('board', default)} (no images)")

    qty_images = len(set(images))
    qty_images_released = len(set(images_released))

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
            meta += "title: Threatos ARM Images\n"
            meta += "---\n\n"

            stats = f"- The official [Threatos ARM repository](https://github.com/threatcode/threatos) contains [build-scripts]((https://github.com/threatcode/threatos)) to create [**{qty_images}** unique Threatos ARM images](image-stats.html) for **{qty_devices}** devices\n"
            stats += f"- The [next release](https://threatcode.github.io/releases/) cycle will include [**{qty_images_released}** Threatos ARM images](image-stats.html) _([ready to download](https://threatcode.github.io/get-threatos/#threatos-arm))_\n"
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
    print(f"Devices        : {qty_devices}")
    print(f"Images         : {qty_images}")
    print(f"Images Released: {qty_images_released}")


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
