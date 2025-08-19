# resolve.sh
#
# Provides functions for auto-resolving trivial conflicts and for handling the resolution of conflicted files.
#
# Functions:
#   auto_resolve_trivial_conflict(lines_ref, start, mid, end)
#     - Attempts to auto-resolve a conflict block if "ours" and "theirs" are identical.
#     - Arguments:
#         lines_ref: name of the array variable containing file lines
#         start: index of the conflict start marker
#         mid: index of the conflict middle marker
#         end: index of the conflict end marker
#     - Uses global variables: tmpfile, total_lines, resolved, i, GREEN, NC
#
#   resolve_conflicted_file(file)
#     - Orchestrates the resolution process for a single conflicted file.
#     - Arguments:
#         file: The path to the conflicted file to resolve
#     - Uses global variables: repo_root, GREEN, RED, YELLOW, CYAN, undo_tmp
#
# Usage:
#   Called from run.sh for each conflicted file.

# Attempts to auto-resolve a conflict block if "ours" and "theirs" are identical.
# Arguments:
#   lines_ref: name of the array variable containing file lines
#   start: index of the conflict start marker
#   mid: index of the conflict middle marker
#   end: index of the conflict end marker
# Uses global variables: tmpfile, total_lines, resolved, i, GREEN, NC
auto_resolve_trivial_conflict() {
    local lines_ref="$1"
    local start="$2"
    local mid="$3"
    local end="$4"
    local -n lines="$lines_ref"

    local ours=""
    local theirs=""
    # Collect "ours" block lines
    for ((j=start+1; j<mid; j++)); do
        ours+="${lines[$j]}"
    done
    # Collect "theirs" block lines
    for ((j=mid+1; j<end; j++)); do
        theirs+="${lines[$j]}"
    done
    # If blocks are identical, auto-resolve
    if [ "$ours" == "$theirs" ]; then
        {
            head -n "$start" "$repo_root/$tmpfile"
            for ((j=start+1; j<mid; j++)); do
                echo "${lines[$j]}"
            done
            tail -n $((total_lines-end-1)) "$repo_root/$tmpfile"
        } > "$repo_root/${tmpfile}.new"
        mv "$repo_root/${tmpfile}.new" "$repo_root/$tmpfile"
        echo -e "${GREEN}Auto-resolved trivial conflict block.${NC}"
        resolved=1
        mapfile -t lines < "$repo_root/$tmpfile"
        total_lines=${#lines[@]}
        i=$((start))
        ((i++))
        return 0
    fi
    return 1
}

# Orchestrates the resolution process for a single conflicted file.
# Arguments:
#   file: The path to the conflicted file to resolve
# Uses global variables: repo_root, GREEN, RED, YELLOW, CYAN, undo_tmp
resolve_conflicted_file() {
    local file="$1"
    echo -e "${RED}============================================================${NC}"
    echo -e "${YELLOW}Conflict detected in: ${CYAN}$file${NC}"

    # Read file into file_lines array
    mapfile -t file_lines < "$repo_root/$file"
    total_lines=${#file_lines[@]}
    i=0
    resolved=0
    tmpfile="${file}.resolved.$$"
    cp "$repo_root/$file" "$repo_root/$tmpfile"

    # Loop through lines to find and process conflict blocks
    while [ $i -lt $total_lines ]; do
        if echo "${file_lines[$i]}" | grep -q '^<<<<<<<'; then
            start=$i
            process_conflict_block file_lines "$start" "$total_lines" "$file" "$repo_root" "$tmpfile"
        fi
        ((i++))
    done

    # Finalize resolution: move or clean up temp file, stage changes
    if [ $resolved -eq 1 ]; then
        mv "$repo_root/$tmpfile" "$repo_root/$file"
        git add "$repo_root/$file"
        echo -e "${GREEN}Resolved conflicts in $file and staged.${NC}"
    else
        rm "$repo_root/$tmpfile"
        echo -e "${YELLOW}No blocks resolved in $file.${NC}"
    fi
    [ -f "$repo_root/$undo_tmp" ] && rm "$repo_root/$undo_tmp"
    echo -e "${RED}============================================================${NC}"
}