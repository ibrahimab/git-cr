# run.sh
#
# Contains the main orchestration logic for git-cr.
#
# This module is responsible for:
#   - Detecting conflicted files in the current git repository.
#   - Validating the repository root.
#   - Displaying the interactive resolver header.
#   - Iterating over each conflicted file and invoking resolution logic.
#   - Showing a summary and git status after all conflicts are processed.
#
# Functions:
#   run
#     - Main orchestration function called by main.sh.
#     - Calls resolve_conflicted_file (from resolve.sh) for each conflicted file.
#
# Usage:
#   Source this file and call run from your main entry point.
#   All required modules (colors.sh, preview.sh, resolve.sh, block.sh) must be sourced before calling run.

source "$(dirname "$0")/colors.sh"
source "$(dirname "$0")/preview.sh"
source "$(dirname "$0")/resolve.sh"
source "$(dirname "$0")/block.sh"

run() {
    # Getting the current working directory, we are going to use it later
    # to restore the original working directory after processing conflicts.
    ORIG_PWD="$(pwd)"

    conflicted_files=$(git diff --name-only --diff-filter=U)

    if [ -z "$conflicted_files" ]; then
        echo -e "${GREEN}No merge conflicts detected.${NC}"
        exit 0
    fi

    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ ! -d "$repo_root" ]; then
        echo -e "${RED}Error: Not inside a git repository.${NC}"
        exit 1
    fi

    cd "$repo_root" || { echo "Failed to cd to repo root: $repo_root"; exit 1; }
    trap 'cd "$ORIG_PWD"' EXIT

    echo -e "${YELLOW}Interactive Git Conflict Resolver (Per Block)${NC}"
    echo -e "${CYAN}---------------------------------------------${NC}"

    undo_tmp=""
    undo_file=""
    undo_block=""

    for file in $conflicted_files; do
        resolve_conflicted_file "$file"
    done

    echo -e "${GREEN}All conflict blocks processed. You can now commit the merge.${NC}"
    echo -e "${CYAN}Git status:${NC}"
    git status
}