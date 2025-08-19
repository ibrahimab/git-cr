# colors.sh
#
# This file defines ANSI color codes and background styles for use throughout the git-cr interactive conflict resolver.
# It also detects and sets the appropriate 'bat' command for syntax highlighting.
#
# Usage:
#   Source this file in your main script or other modules to use the color variables and $BAT.
#
# Color Variables:
#   RED, GREEN, YELLOW, BOLD_YELLOW, CYAN
#   BLUE_BG, MAGENTA_BG, YELLOW_BG, DIFF_BG
#   MARKER_BG, MARKER_FG, ORANGE, NC (reset/no color)
#
# BAT detection:
#   Sets $BAT to 'bat' or 'batcat' depending on which is available.

RED='\033[0;31m'           # Red foreground
GREEN='\033[0;32m'         # Green foreground
YELLOW='\033[1;33m'        # Yellow foreground
BOLD_YELLOW='\033[1;33;1m' # Bold yellow foreground
CYAN='\033[0;36m'          # Cyan foreground

BLUE_BG='\033[44m\033[97m'     # Blue background, white text
MAGENTA_BG='\033[45m\033[97m'  # Magenta background, white text
YELLOW_BG='\033[43m\033[30m'   # Yellow background, black text
MARKER_BG='\033[45m'           # Magenta background (for conflict markers)
MARKER_FG='\033[97m'           # White foreground (for conflict markers)
DIFF_BG='\033[43m\033[97m'     # Yellow background, white text (for "theirs" block)
ORANGE='\033[38;5;208m'        # Orange foreground (for undo option)
NC='\033[0m'                   # Reset/no color

# Detect bat or batcat for syntax highlighting
if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
    BAT="batcat"
else
    BAT="bat"
fi