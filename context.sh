# context.sh
#
# Provides functions for extracting and displaying the context around a conflict block.
# Uses bat for syntax highlighting and applies custom coloring to conflict markers and diff sections.
#
# Function:
#   print_conflict_context
#     - Reads a context range from the file and highlights it using bat.
#     - Colors conflict markers (<<<<<<<, =======, >>>>>>>) and diff sections for clarity.
#     - Handles "ours" and "theirs" block coloring within the context.

print_conflict_context() {
    local file="$1"           # Path to the file being processed
    local context_start="$2"  # Start line of context
    local context_end="$3"    # End line of context
    local lang="${4:-}"       # Language for bat syntax highlighting (optional)

    # Get highlighted context from bat
    local bat_output
    if [ -n "$lang" ]; then
        bat_output=$("$BAT" --color=always --style=plain --language="$lang" --line-range "$((context_start+1)):$((context_end))" "$file")
    else
        bat_output=$("$BAT" --color=always --style=plain --line-range "$((context_start+1)):$((context_end))" "$file")
    fi
    if [ $? -ne 0 ] || [ -z "$bat_output" ]; then
        echo "Error: Failed to get context from bat for $file" >&2
        return 1
    fi

    local line_num=0
    local in_ours=0
    local in_theirs=0

    # Read each line of bat output and apply custom coloring
    while IFS= read -r bat_line; do
        # Remove ANSI color codes for easier pattern matching
        local plain_line
        plain_line=$(echo "$bat_line" | sed 's/\x1b\[[0-9;]*m//g')

        # Detect conflict markers and set coloring/state
        if [ "$(echo "$plain_line" | grep '^<<<<<<<')" != "" ]; then
            echo -e "${MARKER_BG}${MARKER_FG}$plain_line${NC}"
            in_ours=1
            in_theirs=0
        elif [ "$(echo "$plain_line" | grep '^=======')" != "" ]; then
            echo -e "${MARKER_BG}${MARKER_FG}$plain_line${NC}"
            in_ours=0
            in_theirs=1
        elif [ "$(echo "$plain_line" | grep '^>>>>>>>')" != "" ]; then
            echo -e "${MARKER_BG}${MARKER_FG}$plain_line${NC}"
            in_ours=0
            in_theirs=0
        elif [ $in_ours -eq 1 ]; then
            echo -e "${BLUE_BG}$plain_line${NC}"
        elif [ $in_theirs -eq 1 ]; then
            echo -e "${DIFF_BG}$plain_line${NC}"
        else
            echo "$bat_line"
        fi
        ((line_num++))
    done <<< "$bat_output"

    return 0
}