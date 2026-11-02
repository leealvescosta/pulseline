#!/bin/bash
# Double-click to install on macOS (first time: right-click > Open).
cd "$(dirname "$0")" && bash ./install.sh
read -n 1 -s -r -p "Press any key to close..."
