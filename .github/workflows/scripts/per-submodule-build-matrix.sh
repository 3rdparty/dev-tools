#!/bin/bash

# We'll print some debug information along the way.
echo "Started in working directory '$(pwd)'..."

# Move to the repository whose submodules we want to sync. By default this
# script assumes it runs from _inside_ a submodule and acts on the repo that
# directly _contains_ that submodule (one level up). When the submodule is
# nested more than one level deep, the caller can set `SUBMODULE_SYNC_ROOT` to
# the target repository's directory (relative to the checkout root) to act on
# that repository instead.
if [ -n "${SUBMODULE_SYNC_ROOT:-}" ]; then
  cd "${GITHUB_WORKSPACE}/${SUBMODULE_SYNC_ROOT}"
else
  cd "$(git rev-parse --show-toplevel)/.."
fi

gitmodules_path="$(git rev-parse --show-toplevel)/.gitmodules"
echo "Assumed relevant '.gitmodules' file is '$gitmodules_path'"

# Update references.
git submodule update --recursive --remote

# The following condition is needed to set required outputs.
# The step generates one output: `path_matrix`.
# `path_matrix` output contains list of all submodules within a repo.
# The flag is used by the main build job.
output=$( \
    echo "path_matrix=[$(git config --file "$gitmodules_path" --get-regexp path | \
      awk '{ print $2 }' | \
      awk '{ printf "%s\"%s\"", (NR==1?"":", "), $0 } END{ print "" }')]" \
)
echo "####"
echo $output
echo "####"
echo $output >> $GITHUB_OUTPUT
