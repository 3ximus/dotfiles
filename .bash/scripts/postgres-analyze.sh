#!/bin/bash

ANALYZE_TMP=${2:-$(mktemp --suffix=.json)}

if [ $# -lt 2 ]; then
	echo -e "usage:\n\t $BASH_SOURCE queryfile planfile"
	echo -e "to generate plan:\n\tpsql DB_URL -XqAt -f explain.sql > plan.json"
	exit 1
fi

id=$(curl -s 'https://explain.dalibo.com/new.json' -X POST --json @<(jq -n --rawfile plan $ANALYZE_TMP --rawfile query $2 '{plan:$plan,query:$query,title:"sample"}') | jq -r '.id')
firefox --new-tab "https://explain.dalibo.com/plan/$id"

[[ -z $2 ]] && rm $ANALYZE_TMP



