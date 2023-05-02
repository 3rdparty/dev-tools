#!/bin/bash
# This script runs the same code checks as are run in our github action runners,
# as specified in `actions.yml`, namely:
# * check_style_of_all_files.sh - clang-format and extra line length checking).
# * check_style_bzl.sh - buildifier, but 10x slower.
# * yapf
# * isort
# * prettier
#


# Unset variable would be a sign of programmer error. We are not using '-e' in
# this script as we'd like to handle these cases ourselves where relevant, i.e.,
# allow more than one code check failure per run.
set -u

# Work from the git root. This is important to help some tools pick up the
# correct configuration.
git_root=$(git rev-parse --show-toplevel)
cd "${git_root}"

# Get all files under version control. These are the superset of files we will
# want to check.
affected_files=$(git ls-tree --full-tree --name-only -r HEAD)

# Define a cummulative status code for the script. The value is Updated through
# 'run_check' when running checks. A status code creater than 0 will indicate
# that one or more checks failed.
status_code=0

# Run a code check command and update the cummulative error code.
run_check() {
    echo $1
    time $@
    status_code=$(($status_code + $?))
}

# Helper function to filter affected files by extension.
get_files_by_extension() {
    filter=""
    for ext in $@; do
        filter="\\.$(echo $ext | sed -e 's|^\.||')$|${filter}"
    done
    filter=$(echo $filter | sed -e 's/|$//')

    echo $affected_files | tr ' ' '\n' | egrep $filter
}

# Check files that we can clang-format.
clang_format_files=$(get_files_by_extension .cc .cpp .h .hpp .proto)
if [ ! -z "${clang_format_files}" ]; then
    # Run clang-format. In fact, run our wrapper script around-clang format that
    # also contains logic for checking the line length.
    #
    # ISSUE https://github.com/reboot-dev/respect/issues/1371: This script is
    # very slow as we process each file sequentially and does the line length
    # checking in bash.
    dev_tools_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    run_check "${dev_tools_path}/check-code-style/check_style_of_all_files.sh"
fi

# Check bazel files
bazel_files=$(get_files_by_extension .bzl .bazel BUILD WORKSPACE)
if [ ! -z "${bazel_files}" ]; then
    # ISSUE https://github.com/reboot-dev/respect/issues/1383: This script is
    # about 10 times slower than invoking buildifier directly and it doesn't do
    # much more.
    dev_tools_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    run_check "${dev_tools_path}/check-code-style/check_style_bzl.sh"
fi

# Check python files.
python_files=$(get_files_by_extension .py)
if [ ! -z "${python_files}" ]; then
    # Run yapf.
    run_check yapf -d -p ${python_files}

    # Run isort
    run_check isort --check --diff ${python_files}
fi

# Check files that we can check with prettier.
# Turns out it is all of them.
if [ ! -z "${affected_files}" ]; then
    # Run prettier.
    run_check prettier --ignore-unknown --check ${affected_files}
fi

# Return the cummulative status code. The status code will be zero if all checks
# completed successfully and non-zero otherwise. If the script exits with a
# non-zero value, the commit is aborted.
exit $status_code
