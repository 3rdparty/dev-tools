#!/bin/bash

source dev-tools/check-code-style/check_style.sh

path_to_find_files_for_checks="."

if [ $# -eq 0 ]
then
  tput bold
  tput setaf 3
  printf "Warning: "
  tput sgr0
  printf "this script will check all files which"
  printf " are located on the path from which this"
  printf " script has been run.\n"
  printf "If you want to check files from the"
  printf " specific path you can run this script" 
  printf " with the argument which specifies this path.\n"
  printf "e.g: some/path/check_style_of_all_files.sh some/dir\n"
elif [ $# -gt 1 ]
then
  tput bold
  tput setaf 1
  printf "Error: "
  tput sgr0
  printf "this script can be run only with 0 or 1 argument"
  printf " which specifies the path where you wanna search"
  printf " files for checking code style.\n"
  exit 1
else
  path_to_find_files_for_checks=$1
fi

# Check every file for correct code style.
check_style_of_all_files() {
  # Find all files we want to check in the workspace.
  IFS=:
  file_paths=$(find ${path_to_find_files_for_checks} -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.proto')
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
