#!/bin/bash
# Shared helper functions for check-style.sh and fix-style.sh.

# Work from the git root. This is important to help some tools pick
# up the correct configuration.
git_root=$(git rev-parse --show-toplevel)
cd "${git_root}"

# Define a cumulative status code. The value is updated through
# `run_check` when running checks. A status code greater than 0
# will indicate that one or more checks failed.
status_code=0

# Run a command and update the cumulative error code.
run_check() {
    "$@"
    status_code=$(($status_code + $?))
}

# Filter `affected_files` by extension(s).
get_files_by_extension() {
    filter=""
    for ext in "$@"; do
        # We want a `.` to be a full stop, not a regexp wildcard.
        filter="$(echo $ext | sed -e 's|^\.|\\.|')$|${filter}"
    done
    filter=$(echo $filter | sed -e 's/|$//')

    echo $affected_files | tr ' ' '\n' | egrep $filter
}

# Get a checksum of a file list. Calculates a per-file checksum,
# sorts by filename, and then returns a sum over the sums.
calculate_checksum() {
    sha256sum "$@" | sort -k 2 | sha256sum
}

# Filter out symlinks from `affected_files`.
filter_symlinks() {
    filtered_files=""
    for f in $affected_files; do
        if [ ! -L "$f" ]; then
            filtered_files="$filtered_files $f"
        fi
    done
    affected_files=$(echo "$filtered_files" | xargs -r)
}
