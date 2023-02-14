#!/bin/bash

set -e

BRANCH_NAME=$(git branch --show-current)
REMOTE=$(git remote get-url origin | sed 's@git\@bitbucket.org:\(.*/.*\).git@\1@')

URL="https://api.bitbucket.org/2.0/repositories/${REMOTE}/pullrequests/"
USERNAME="fabio_almeida_vo2"

read -p "API Token file [.bitbucket_api.key]: " APIKEY
APIKEY=${APIKEY:-$(cat .bitbucket_api.key)}
read -p "Title: " TITLE
TITLE="${BRANCH_NAME} ${TITLE}"
read -p "Target [dev]: " TARGET_BRANCH
TARGET_BRANCH=${TARGET_BRANCH:-dev}

echo -e "PR: \e[32m$BRANCH_NAME\e[m > \e[1;34m$TARGET_BRANCH\e[m : $TITLE ($APIKEY)"
echo -e "Username: \e[33m${USERNAME}\e[m"
echo "URL: ${URL}"
read -p 'Press any key to continue... '

curl -i -X POST \
  -u "${USERNAME}:${APIKEY}" \
  -H "Content-Type: application/json" \
  -d "{
      \"title\": \"${TITLE}\",
      \"source\": {
        \"repository\": { \"full_name\": \"${REMOTE}\" },
        \"branch\": { \"name\": \"${BRANCH_NAME}\" }
      },
      \"destination\": { \"branch\": { \"name\": \"${TARGET_BRANCH}\" } },
      \"description\": \"\",
      \"close_source_branch\": true,
      \"reviewers\": [
        { \"account_id\": \"5d94bd8d5247770c24548801\" },
        { \"account_id\": \"5f6e109058ea7b007091eb32\" }
      ]
    }" $URL
