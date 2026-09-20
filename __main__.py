#!/usr/bin/env python3
"""NovaMoFu (模糊) — CLI Entry Point"""

import sys
import os
import subprocess
import json


def main():
    if len(sys.argv) < 2:
        print("Usage: python -m novamofu <video_url_or_path> [--mode seedance|sora|runway|generic]")
        print("       python -m novamofu --check")
        sys.exit(1)

    # Find analyzer.sh
    script_dir = os.path.dirname(os.path.abspath(__file__))
    analyzer = os.path.join(script_dir, "engine", "analyzer.sh")

    if not os.path.exists(analyzer):
        print(f"ERROR: analyzer.sh not found at {analyzer}")
        sys.exit(1)

    # Forward all args to analyzer.sh
    cmd = ["bash", analyzer] + sys.argv[1:]
    result = subprocess.run(cmd, capture_output=False)

    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
