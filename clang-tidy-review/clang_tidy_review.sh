#!/bin/bash

# We need this export to enable color output to the terminal using GitHub
# Actions. If no, we will get the error while using commands in bash such
# as `tput`.
export TERM=xterm-color

# Check if there is clang-tidy installed.
clang-tidy --version >/dev/null
if [[ ${?} != 0 ]]; then
  tput setaf 1 # Red font in terminal.
  printf "Error: failed to find 'clang-tidy'.\n"
  tput sgr0 # Make font be default in terminal.
  printf "Make sure you have clang-tidy installed!\n"
  exit 1
fi

# Check for existence of compile_commands.json.
IFS=:
compilation_database=$(find . -name 'compile_commands.json')
unset IFS

if [[ ${#compilation_database} == 0 ]]; then
  tput setaf 1 # Red font in terminal.
  printf "Error: there is no compilation database "
  printf "(compile_commands.json) in your workspace!\n"
  tput sgr0 # Make font be default in terminal.
  exit 1
fi

# Check for existence of .clang-tidy.
IFS=:
clang_tidy_config_file=$(find . -name '\.clang-tidy')
unset IFS

if [[ ${#clang_tidy_config_file} == 0 ]]; then
  tput setaf 1 # Red font in terminal.
  printf "Error: there is no .clang-tidy config file in your workspace!\n"
  tput sgr0 # Make font be default in terminal.
  exit 1
fi

# Find all source files (.cc|.cxx|.cpp|.c) we want to check with clang-tidy.
# We do not include headers since clang-tidy has `--header-filter` option or
# `HeaderFilterRegex` option (in .clang-tidy). With the help of this option
# we can easily grab all warnings|errors from headers included in the source
# files.
IFS=:
source_files=$(find . -name '*.cc' -o -name '*.cpp' -o -name '*.cxx')
unset IFS

# Exit with success if there is no work to do.
if [[ ${#source_files} == 0 ]]; then
  tput setaf 2 # Green font in terminal.
  printf "There are no source files to check with clang-tidy!\n"
  tput sgr0 # Reset terminal.
  exit 0
fi

status_exit=0

# Run clang-tidy checks for every file.
for file in ${source_files}
do
  printf "Run clang-tidy on ${file} ...\n"

  clang-tidy --config-file="${clang_tidy_config_file}" \
  -p ${compilation_database} ${file} -- -std=c++17 \
  -I$(bazel info workspace) \
  -I$(bazel info workspace)/bazel-bin/external/com_github_google_glog/src \
  -I$(bazel info workspace)/bazel-bin/external/com_github_google_glog/_virtual_includes/glog \
  -I$(bazel info workspace)/bazel-bin/external/com_github_gflags_gflags/_virtual_includes/gflags \
  -I$(bazel info workspace)/bazel-bin/external/com_github_libuv_libuv/libuv/include \
  -I$(bazel info workspace)/external/com_github_google_googletest/googlemock/include \
  -I$(bazel info workspace)/external/com_github_google_googletest/googletest/include \
  -I$(bazel info workspace)/external/com_github_curl_curl/include \
  -I$(bazel info workspace)/external/com_github_chriskohlhoff_asio/asio/include \
  -I$(bazel info workspace)/external/boringssl/src/include
      
  clang_tidy_status=$(echo $?)
  if [[ ${clang_tidy_status} != 0 ]]
  then
    tput setaf 1 # Red font in terminal.
    printf "Error: ${file} needs to be fixed from clang-tidy warnings.\n"
    tput sgr0 # Reset terminal.
    status_exit=1
  fi
done

exit ${status_exit}
