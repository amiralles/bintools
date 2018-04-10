#!/bin/bash
# Shows only the file names (only) that had change since the specified commit.
# (By default, it shows the latest five commits.)
SINCE=HEAD~5
if [ "$1" != "" ]; then
	SINCE="$1"
fi

git diff $SINCE --name-only | sort | uniq
