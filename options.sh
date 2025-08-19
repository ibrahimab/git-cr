# options.sh
#
# Provides functions for displaying resolution options to the user and handling their choices
# during interactive conflict resolution.
#
# Functions:
#   print_options(file)
#     - Displays available resolution choices for the current conflict block.
#   handle_resolution_choice(file, tmpfile, start, mid, end)
#     - Prompts the user for a choice and applies the selected resolution.
#     - Supports preview, undo, skip, cancel, and abort actions.
#
# Usage:
#   Called from block.sh after displaying the conflict context.
#

# Prints the available resolution options for the current conflict block.
# Arguments:
#   $1 - file: The file currently being resolved
print_options() {
    local file="$1"
    echo -e "${CYAN}------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Choose resolution for this block in ${CYAN}$file${NC}:"
    echo -e "  ${BLUE_BG}(c) Use current branch (ours)${NC}"      # Keep changes from current branch
    echo -e "  ${DIFF_BG}(i) Use incoming branch (theirs)${NC}" # Keep changes from incoming branch
    echo -e "  ${CYAN}(s) Skip this block${NC}"                  # Skip and resolve later
    echo -e "  ${YELLOW}(q) Cancel and exit script${NC}"         # Cancel and exit without changes
    echo -e "  ${RED}(m) Abort merge and exit${NC}"              # Abort the merge operation
    echo -e "  ${ORANGE}(u) Undo last resolution${NC}"           # Undo the last applied resolution
}

# Handles the user's choice for resolving the current conflict block.
# Arguments:
#   $1 - file:      The file being resolved
#   $2 - tmpfile:   Temporary file for staged changes
#   $3 - start:     Start index of the conflict block
#   $4 - mid:       Middle index (separator line)
#   $5 - end:       End index of the conflict block
handle_resolution_choice() {
    local file="$1"
    local tmpfile="$2"
    local start="$3"
    local mid="$4"
    local end="$5"
    while true; do
        read -p "Your choice (c/i/s/q/m/u): " choice
        case "$choice" in
            c|i)
                # Show a preview of the chosen resolution before applying
                preview_resolution "$choice" "$start" "$mid" "$end" lines "$lang"
                read -p "Apply this resolution? (y/n): " confirm
                if [ "$confirm" != "y" ]; then
                    continue
                fi
                # Save undo info for possible rollback
                undo_tmp="$tmpfile.undo"
                cp "$repo_root/$tmpfile" "$repo_root/$undo_tmp"

                undo_file="$file"
                undo_block="$start"
                
                if [ "$choice" == "c" ]; then
                    # Apply "ours" block (current branch)
                    { 
                        head -n $start "$tmpfile"
                        for ((j=start+1; j<mid; j++)); do
                            echo "${lines[$j]}"
                        done
                        tail -n $((total_lines-end-1)) "$tmpfile"
                    } > "${tmpfile}.new"
                else
                    # Apply "theirs" block (incoming branch)
                    {
                        head -n $start "$tmpfile"
                        for ((j=mid+1; j<end; j++)); do
                            echo "${lines[$j]}"
                        done
                        tail -n $((total_lines-end-1)) "$tmpfile"
                    } > "${tmpfile}.new"
                fi
                mv "${tmpfile}.new" "$tmpfile"
                echo -e "${GREEN}Resolution applied.${NC}"
                resolved=1
                break
                ;;
            u)
                # Undo the last resolution if possible
                if [ -f "$repo_root/$undo_tmp" ]; then
                    mv "$repo_root/$undo_tmp" "$repo_root/$tmpfile"
                    echo -e "${GREEN}Undo successful. Last resolution reverted.${NC}"
                    mapfile -t lines < "$tmpfile"
                    total_lines=${#lines[@]}
                    i=$((undo_block))
                    break
                else
                    echo -e "${RED}No resolution to undo.${NC}"
                fi
                ;;
            s)
                # Skip this block, user will resolve it manually later
                echo -e "${YELLOW}Skipped this block. Resolve it manually later.${NC}"
                break
                ;;
            q)
                # Cancel and exit the script, no changes committed
                echo -e "${RED}Cancelling conflict resolution. No changes committed.${NC}"
                rm "$repo_root/$tmpfile"
                [ -f "$repo_root/$undo_tmp" ] && rm "$repo_root/$undo_tmp"
                exit 1
                ;;
            m)
                # Abort the merge operation and exit
                echo -e "${RED}Aborting merge and exiting.${NC}"
                rm "$repo_root/$tmpfile"
                [ -f "$repo_root/$undo_tmp" ] && rm "$repo_root/$undo_tmp"
                git merge --abort
                exit 2
                ;;
            *)
                # Invalid choice, prompt again
                echo -e "${RED}Invalid choice. Please enter c, i, s, q, m, or u.${NC}"
                ;;
        esac
    done

    # Refresh lines and indices after resolution
    mapfile -t lines < "$tmpfile"
    total_lines=${#lines[@]}
    i=$((start))
}