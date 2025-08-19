# block.sh
#
# This module orchestrates the processing of individual conflict blocks within a conflicted file.
# It sources context.sh for context extraction and coloring, and options.sh for user interaction and resolution logic.
#
# Functions:
#   process_conflict_block
#     - Locates the boundaries of a conflict block (start, mid, end).
#     - Attempts auto-resolution for trivial conflicts.
#     - Extracts and displays surrounding context for the block.
#     - Determines syntax highlighting language based on file extension.
#     - Delegates context display and user interaction to helper modules.
#
# Usage:
#   Called from the main file loop for each detected conflict block.

source "$(dirname "$0")/context.sh"
source "$(dirname "$0")/options.sh"

process_conflict_block() {
    local lines_ref="$1"      # name of array variable
    local start="$2"
    local total_lines="$3"
    local file="$4"
    local repo_root="$5"
    local tmpfile="$6"

    local -n lines="$lines_ref"  # Bash nameref for array

    local mid=$((start+1))
    while [ $mid -lt $total_lines ] && [ "$(echo "${lines[$mid]}" | grep '^=======')" = "" ]; do
        ((mid++))
    done
    local end=$((mid+1))
    while [ $end -lt $total_lines ] && [ "$(echo "${lines[$end]}" | grep '^>>>>>>>')" = "" ]; do
        ((end++))
    done

    auto_resolve_trivial_conflict "$lines_ref" "$start" "$mid" "$end"
    if [ $? -eq 0 ]; then
        return
    fi

    local context_start=$((start-10))
    [ $context_start -lt 0 ] && context_start=0
    local context_end=$((end+10))
    [ $context_end -gt $total_lines ] && context_end=$total_lines

    echo -e "${CYAN}------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Conflict block around lines $((start+1))-$((end+1)):${NC}"

    local ext="${file##*.}"
    local lang=""
    case "$ext" in
        py) lang="python" ;;
        js) lang="javascript" ;;
        sh) lang="bash" ;;
        json) lang="json" ;;
        yml|yaml) lang="yaml" ;;
        # No default, leave lang empty for unknown types
    esac

    if [ -n "$lang" ]; then
        print_conflict_context "$repo_root/$file" "$context_start" "$context_end" "$lang"
    else
        print_conflict_context "$repo_root/$file" "$context_start" "$context_end"
    fi

    print_options "$file"
    handle_resolution_choice "$file" "$tmpfile" "$start" "$mid" "$end"
}