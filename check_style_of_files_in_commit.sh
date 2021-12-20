#!/bin/bash

source check_style.sh

# Check files that are part of the current commit.
check_style_of_files_in_commit() {
  local -i status=0
  files=$(git diff --cached --name-only --diff-filter=ACM HEAD | grep -iE '\.(cc|h)$')
  for file in ${files}; do
    check_style "${file}"

    if [[ ${?} != 0 ]]; then
      status=1
    fi
  done

  return ${status}
}
