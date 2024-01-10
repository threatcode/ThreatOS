#!/usr/bin/env python3
# REF: https://threatcode.github.io/docs/arm/

import sys
from datetime import datetime

import yaml  # python3 -m pip install pyyaml --user

OUTPUT_FILE = "./image-overview.md"
INPUT_FILE = "./devices.yml"

repo_msg = f"""
_This table was [generated automatically](https://github.com/threatcode/threatos/-/blob/master/devices.yml) on {datetime.now().strftime('%Y-%B-%d %H:%M:%S')} from the [Threatos ARM GitLab repository](https://github.com/threatcode/threatos)_
"""

qty_devices = 0
qty_images = 0
qty_image_threatos = 0
qty_image_community = 0
qty_image_eol = 0
qty_image_unknown = 0

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
    global qty_devices, qty_images, qty_image_threatos, qty_image_community, qty_image_eol, qty_image_unknown

    images = []

    default = ""

    table = "| [Device Name](https://threatcode.github.io/docs/arm/) | [Build-Script](https://github.com/threatcode/threatos/) | [Official Image](https://threatcode.github.io/get-threatos/#threatos-arm) | Community Image | EOL/Retired Image |\n"
    table += "|---------------|--------------|----------------|-----------------|---------------|\n"

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
                            if image["name"] not in images:
                                # ALT: images.append(image["image"])
                                images.append(image["name"])

                                qty_images += 1

                                build_script = image.get(
                                    "build-script",
                                    default
                                )

                                if build_script:
                                    build_script = f"[{build_script}](https://github.com/threatcode/threatos/-/blob/master/{build_script})"

                                name = image.get("name", default)
                                slug = image.get("slug", default)

                                if name and slug:
                                    name = f"[{name}](https://threatcode.github.io/docs/arm/{slug}/)"

                                support = image.get("support", default)

                                if support == "threatos":
                                    status = "x |  | "
                                    qty_image_threatos += 1

                                elif support == "community":
                                    status = " | x | "
                                    qty_image_community += 1

                                elif support == "eol":
                                    status = " |  | x"
                                    qty_image_eol += 1

                                else:
                                    status = " |  | "
                                    qty_image_unknown += 1

                                table += f"| {name} | {build_script} | {status} |\n"

                            # else:
                            #    print(f"DUP {image["name"]} / {image["image"]}")

                if "images" not in board.keys():
                    print(f"[i] Possible issue with: {board.get('board', default)} (no images)")

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
            meta += "title: Threatos ARM Image Overview\n"
            meta += "---\n\n"

            stats = f"- The official [Threatos ARM repository](https://github.com/threatcode/threatos) contains [build-scripts]((https://github.com/threatcode/threatos)) to create [**{qty_images}** unique Threatos ARM images](image-stats.html) for **{qty_devices}** devices\n"
            stats += f"- The [next release](https://threatcode.github.io/releases/) cycle will include [**{qty_image_threatos}** Threatos ARM images](image-stats.html) _([ready to download](https://threatcode.github.io/get-threatos/#threatos-arm))_, **{qty_image_community}** images which can be [built](https://github.com/threatcode/threatos), and {qty_image_eol} retired images\n"
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
    print(f"Devices: {qty_devices}")
    print(f"Images : {qty_images}")
    print(f"- Threatos     : {qty_image_threatos}")
    print(f"- Community: {qty_image_community}")
    print(f"- EOL      : {qty_image_eol}")
    print(f"- Unknown  : {qty_image_unknown}")


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
