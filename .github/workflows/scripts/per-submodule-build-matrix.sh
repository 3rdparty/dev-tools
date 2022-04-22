#!/bin/bash

# Update references.
git submodule update --recursive --remote

# The following condition is needed to set required outputs.
# The step generates one output: `path_matrix`.
# `path_matrix` output contains list of all submodules within a repo.
# The flag is used by the main build job.
echo "::set-output name=path_matrix::[$(git config --file ../../../.gitmodules --get-regexp path | \
awk '{ print $2 }' | \
awk '{ printf "%s\"%s\"", (NR==1?"":", "), $0 } END{ print "" }')]"
