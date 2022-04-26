#!/bin/bash

PR_TITLE=$1
ISSUE_TITLE=$2

# The API URLs in conditions below search for any existing pull requests and issues using wildcard and
# generates ISSUE_EXISTS and PR_EXISTS environment variables and places those in the environment for next steps
# through $GITHUB_ENV;
# See https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-environment-variable
# See docs: https://docs.github.com/en/rest/reference/search#search-issues-and-pull-requests--parameters
# If the issue exists we also set the `ISSUE_NUMBER` environment variable.

PR_NUMBER=$(curl -s --request GET \
  --url https://api.github.com/search/issues\?q=is:pull-request+is:open+repo:$REPO+in:title+$PR_TITLE \
  --header "Authorization: token $GITHUB_TOKEN" | jq -r ".items[].number" | head -n 1);
ISSUE_NUMBER=$(curl -s --request GET \
  --url https://api.github.com/search/issues\?q=is:issue+is:open+repo:$REPO+in:title+$ISSUE_TITLE \
  --header "Authorization: token $GITHUB_TOKEN" | jq -r ".items[].number" | head -n 1);
echo "ISSUE_NUMBER=$ISSUE_NUMBER" >> $GITHUB_ENV;
echo "ISSUE_EXISTS=$(if [[ $ISSUE_NUMBER ]]; then echo 'true'; else echo 'false'; fi)" >> $GITHUB_ENV;
echo "PR_NUMBER=$PR_NUMBER" >> $GITHUB_ENV;
echo "PR_EXISTS=$(if [[ $PR_NUMBER ]]; then echo 'true'; else echo 'false'; fi)" >> $GITHUB_ENV;
