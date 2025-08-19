#!/bin/bash
# build.sh
#
# This script builds the git-cr interactive conflict resolver into a single executable.
# It concatenates all module files, removes any 'source' statements, and compiles the result into a binary using shc.
# The final binary is installed to /usr/local/bin for system-wide use.
#
# Steps:
#   1. Concatenate all source files into one script with a single shebang.
#   2. Remove all 'source' lines to avoid missing file errors.
#   3. Make the script executable.
#   4. Compile the script into a binary using shc (must be installed).
#   5. Copy the binary to /usr/local/bin as 'git-cr'.
#
# Usage:
#   Run this script from the project directory:
#     ./build.sh
#
# Requirements:
#   - All module files (colors.sh, preview.sh, resolve.sh, context.sh, options.sh, block.sh, main.sh) must be present.
#   - shc must be installed (sudo apt-get install shc).
#   - Sudo privileges required to copy binary to /usr/local/bin.

OUT="git-cr"
BIN="git-cr.bin"

echo '#!/bin/bash' > "$OUT"
for part in colors.sh preview.sh resolve.sh context.sh options.sh block.sh run.sh main.sh; do
    echo "" >> "$OUT"
    # Remove 'source' lines during concatenation
    grep -v '^source ' "$part" >> "$OUT"
    echo "" >> "$OUT"
done

chmod +x "$OUT"

if ! command -v shc &> /dev/null; then
    echo "Error: shc is not installed. Please install shc and rerun this script."
    exit 1
fi

shc -f "$OUT" -o "$BIN"

sudo cp "$BIN" /usr/local/bin/git-cr

# Cleanup generated files
rm -f "$OUT" "$BIN" "${OUT}.x.c"

echo "Build complete. Binary installed to /usr/local/bin/git-cr"