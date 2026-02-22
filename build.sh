#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

clang -fobjc-arc target-autoenter.m \
    -framework Cocoa \
    -framework CoreGraphics \
    -framework Carbon \
    -O2 -Wall -Wextra \
    -o target-autoenter

echo "build done → ./target-autoenter"
