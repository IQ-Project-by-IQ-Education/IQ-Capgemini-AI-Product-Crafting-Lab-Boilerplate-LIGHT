#!/bin/bash
# Starts the app on this Mac (built-in macOS tools only, nothing to install).
# Reuses the way /kickoff chose (localhost or file). Double-clicking index.html also works in file mode.
cd "$(dirname "$0")" && bash tools/launch.sh restart --open
