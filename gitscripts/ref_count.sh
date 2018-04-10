#!/bin/bash

# Find classes names on a given file.
function find_classes {
	filename=$1
	# Possible matches:
	# class foo
	# public class foo
	# public abstract class foo
	awk '$1=="class" { print $2};
	     $2=="class" { print $3};
	     $3=="class" { print $4};
		 ' <(grep "class " $filename)
}

# Count references to classes on a given file.
function ref_count {
	filename=$1
	tmpfile=$2
	while read -r name
	do
		grep "$name" "$filename" | \
		wc -l | \
		xargs echo $name | \
		awk '{print $2, $1}'
	done < "$tmpfile"
}

# Find classes and count references.
function find_and_count {
	# TODO: Do we need a tmp file?
	TMPFILE='.cls.tmp'
	for fname in "$@"
	do
		find_classes "$fname" > "$TMPFILE"
		ref_count "$fname" "$TMPFILE" | sort -r
	done
}

function missing_name {
	echo "gitmine => Missing file name or pattern."
	echo "For instance:"
   	echo "gitmine refcount foo.cs"
	echo "gitmine refcount '*.cs'"
	exit
}

function invalid_op {
	echo "Invalid option"
	exit
}

export -f find_classes
export -f ref_count
export -f find_and_count
export -f missing_name
export -f invalid_op

if [[ "$#" -ne 2 || -z $2 || '' = $2 || "''" = $2 ]]; then
	missing_name
fi

# echo "find '$1' -type f -name $2"
# bash -c "find '$1' -type f -name $2"
# echo "done!"
# exit

files=$(bash -c "find '$1' -type f -name $2" | wc -l)
echo "gitmine will refcount $files files. This may take a while..."
read -p "Do you want to continue (y/n)? " choice

case "$choice" in 
	y|Y ) echo "yes";;
	n|N ) exit;;
	  * ) invalid_op;;
esac


bash -c "find '$1' -type f -name $2" | \
   	xargs bash -c 'find_and_count "$@"' _ | \
	awk '{ names[$2] += $1; };
		 END { for(name in names) { 
			printf "%-6d %s \n", names[name], name 
		}}' | \
	sort -rn | \
	less





