# main.sh
#
# Entry point for git-cr interactive conflict resolver.
#
# This script is responsible for:
#   - Sourcing the main orchestration module (run.sh).
#   - Defining and calling the main() function, which delegates to run().
#
# Usage:
#   Execute this script to start the interactive conflict resolution process.
#   All required modules must be present and properly sourced in run.sh.

source "$(dirname "$0")/run.sh"

main() {
    run
}

main