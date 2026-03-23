#!/bin/bash
# Fix formatting of files with unstaged changes in the git repo.


# Source shared helper functions.
dev_tools_path=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${dev_tools_path}/style-helpers.sh"

# Get files with unstaged changes only (not staged; we assume that those have
# already been formatted).
affected_files=$(git diff --name-only 2>/dev/null)

# If there's nothing to do, exit early.
if [ -z "${affected_files}" ]; then
    exit 0
fi

# Filter out symlinks.
filter_symlinks

# Filter to only files that actually exist (not deleted).
existing_files=""
for f in $affected_files; do
    if [ -f "$f" ]; then
        existing_files="$existing_files $f"
    fi
done
affected_files=$(echo "$existing_files" | xargs -r)

if [ -z "${affected_files}" ]; then
    exit 0
fi

# Fix C/C++/proto files with clang-format.
clang_format_files=$(get_files_by_extension .cc .cpp .h .hpp .proto)
if [ ! -z "${clang_format_files}" ]; then
    run_check clang-format -i ${clang_format_files}
fi

# Fix Bazel files with buildifier.
bazel_files=$(get_files_by_extension .bzl .bazel BUILD WORKSPACE)
if [ ! -z "${bazel_files}" ]; then
    run_check buildifier --lint=fix --warnings=all ${bazel_files}
fi

# Fix Python files.
python_files=$(get_files_by_extension .py)
if [ ! -z "${python_files}" ]; then
    run_check ruff check --fix ${python_files}
    run_check isort ${python_files}
    run_check yapf -i -p ${python_files}
fi

# Fix all files with prettier.
run_check prettier --write --ignore-unknown \
    --loglevel=warn ${affected_files}

# Recurse into submodules that have unstaged changes. Only do this from the
# top-level invocation (not from a recursive call inside a submodule) to avoid
# infinite recursion.
if [ -z "${_FIX_STYLE_RECURSING:-}" ]; then
    export _FIX_STYLE_RECURSING=1
    dirty_submodules=$(git submodule status --recursive \
        2>/dev/null | grep '^+' | awk '{print $2}')
    for submodule in $dirty_submodules; do
        if [ -d "$submodule" ]; then
            (cd "$submodule" && \
                "${dev_tools_path}/fix-style.sh")
            status_code=$(($status_code + $?))
        fi
    done
fi

exit $status_code
