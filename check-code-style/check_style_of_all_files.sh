#!/bin/bash

source $(dirname "$0")/check_style.sh

# Check every file for correct code style.
check_style_of_all_files() {
  # Find all files we want to check in the workspace.
  IFS=:
  file_paths=$(find . -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.proto')
  unset IFS

  if [[ ${#file_paths} == 0 ]]; then
    printf "There are no files to check!\n"
    return 0
  fi

  local -i status=0

  for file in ${file_paths}; do
    check_style "${file}"

    if [[ $? != 0 ]]; then
      status=1
    fi
  done

  return ${status}
}

check_style_of_all_files
