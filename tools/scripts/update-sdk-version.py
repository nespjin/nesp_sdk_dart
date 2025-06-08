#!/usr/bin/env python3

import logging
import sys
import config


def update_sdk_version(version):
    old_version = None
    content = ''
    with open("pubspec.yaml", "r") as f:
        is_in_environment = False
        for line in f:
            if line.startswith("environment:"):
                is_in_environment = True
            elif line.strip().startswith("sdk:") and is_in_environment:
                old_version = line.split(":")[1].strip()
                logging.info("Updating sdk version from %s to %s",
                             old_version, version)
                line = "  sdk: " + version + "\n"
                # line = "  sdk: " + version + "\n\n"
                # line += "resolution: workspace\n"
                is_in_environment = False
            content += f"{line}"

    with open("pubspec.yaml", "w") as f:
        f.write(content)


def main():
    sdk_version = config.SDK_VERSION
    if len(sys.argv) >= 2:
        sdk_version = sys.argv[1]
    update_sdk_version(sdk_version)


if __name__ == "__main__":
    sys.exit(main())
