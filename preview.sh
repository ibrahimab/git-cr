# preview.sh
#
# Provides a function for previewing the resolved block before applying changes.
#
# Functions:
#   preview_resolution(choice, start, mid, end, lines, lang)
#     - Shows a syntax-highlighted preview of the block that would be kept based on the user's choice.
#     - Uses bat for syntax highlighting.
#
# Arguments:
#   $1 - choice: 'c' for current branch (ours), 'i' for incoming branch (theirs)
#   $2 - start:  Start index of the conflict block
#   $3 - mid:    Middle index (separator line)
#   $4 - end:    End index of the conflict block
#   $5 - lines:  Array of lines from the file
#   $6 - lang:   Language for bat syntax highlighting


preview_resolution() {
    local choice="$1"      # User's choice: 'c' for ours, 'i' for theirs
    local start="$2"       # Start index of the conflict block
    local mid="$3"         # Index of the separator line (=======)
    local end="$4"         # End index of the conflict block
    local -n lines_ref="$5" # Nameref to the array of file lines
    local lang="$6"        # Language for bat syntax highlighting

    echo -e "${CYAN}Preview of resolved block:${NC}"
    preview_tmp=$(mktemp)
    if [ "$choice" == "c" ]; then
        # Preview "ours" block
        for ((j=start+1; j<mid; j++)); do
            echo "${lines_ref[$j]}"
        done > "$preview_tmp"
    else
        # Preview "theirs" block
        for ((j=mid+1; j<end; j++)); do
            echo "${lines_ref[$j]}"
        done > "$preview_tmp"
    fi

    if [ -n "$lang" ]; then
        $BAT --color=always --style=plain --language="$lang" "$preview_tmp"
    else
        $BAT --color=always --style=plain "$preview_tmp"
    fi
    rm "$preview_tmp"
}