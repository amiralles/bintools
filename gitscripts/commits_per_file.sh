#!/bin/bash
# It shows file names and commits count in descending order, which means you
# get to see the files that change the most first.
# It's also possible to specify an author and only see commits made 
# by that person.
git log --name-only --author=$1 --pretty=format: | sort | uniq -c | sort -nr | less

