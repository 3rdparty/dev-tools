# !/bin/bash

file=$1

commit=$(git log -n 1 --pretty=format:"%H")
shallow_since=$(git log -n 1 --date=raw --pretty=format:"%cd")

git_repository_needed=False

while IFS= read -r line
do
  if [[ "${line}" =~ .*"name = \"com_github_3rdparty_eventuals\"".* ]];
  then
    git_repository_needed=True
    echo "line with name of git_repository needed: ${line}"
  fi

  if [[ "${line}" =~ .*"commit = ".* ]];
  then
    if [ $git_repository_needed = True ];
    then
      new_commit_replace="commit = \"${commit}\","
      sed -i "s/$line/$new_commit_replace/" $file
      echo $new_commit_replace
    fi    
  fi

  if [[ "${line}" =~ .*"shallow_since = ".* ]];
  then
    if [ $git_repository_needed = True ];
    then
      new_shallow_replace="shallow_since = \"${shallow_since}\","
      sed -i "s/$line/$new_shallow_replace/" $file
      echo $new_shallow_replace
    fi    
  fi

done < "$file"

# Check for existence of buildifier.
which buildifier >/dev/null
if [[ $? != 0 ]]; then
  printf "Failed to find 'buildifier'\n"
  exit 1
fi

buildifier $file
