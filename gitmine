#!/bin/bash

# Find classes names on a given file.
function find_classes {
	filename=$1
	# Possible matches:
	# class foo
	# public class foo
	# public abstract class foo
	# TODO: Add partials.
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
   	echo "gitmine refc foo.cs"
	echo "gitmine refc '*.cs'"
	exit 1
}

function invalid_op {
	echo "Invalid option"
	exit 1
}

function ref_count {
	if [[ "$#" -ne 2 || -z $2 || '' = $2 || "''" = $2 ]]; then
		missing_name
	fi

	files=$(bash -c "find '$1' -type f -name $2" | wc -l)
	if [ $files -eq 0 ]; then
		echo "There are no files."
		exit 1
	fi

	echo "gitmine will refcount $files files. This may take a while..."
	read -p "Do you want to continue (y/n)? " choice

	case "$choice" in 
		y|Y ) echo "yes";;
		n|N ) exit;;
		* ) invalid_op;;
	esac

	bash -c "find '$1' -type f -name $2" | \
		xargs bash -c 'find_and_count "$@"' _ | \
		awk "{ names[$2] += $1; }; 
			 END { for(name in names) { 
					printf \"%-6d %s \n\", names[name], name 
				}
			}"   | \
		sort -rn | \
		less
}

function print_score {
	# where $1 points to the author's name.
	awk "{ names[\$1] += 1; }; 
		END { for (n in names) printf(\"|%8d | %-23s |\n\", names[n], n)}"
}

function hi {
	fname="$1"
	echo ""
	echo "+-----------------------------------+"
	echo "| Commits | Author                  |"
	echo "+-----------------------------------+"
	git log --pretty=format:"%an" -- $fname | \
	print_score | \
	sort -nr
	echo "+-----------------------------------+"
	echo ""
	echo ""
}

# It shows file names and commits count in descending order, which means that 
# you get to see the files that change most ofthen first.
# It's also possible to specify an author and see commits made 
# by that person only.
function commits_per_file {
	git log --name-only --author=$1 --pretty=format: |\
		sort | uniq -c | sort -nr | less
}

# commits since until
function commits_since_until {
	if [ "$1" == "" ] || [ "$2" == "" ];
	then
		echo ""
		echo "Command: Show commits since until."
		echo "ERR: Arguments <since> and <until> are both required."
		echo "Tip: You can also filter by <author>."
		echo ""
		exit 1
	fi

	# Filter by author?
	if [ "$3" != "" ]; then
		git log --since $1 --until $2 \
			--pretty=format:"%C(yellow)%h %Creset%ad %C(blue)%an %Creset%s" \
			--date=short --author $3 \
			--reverse
	else
		git log --since $1 --until $2 \
			--pretty=format:"%C(yellow)%h %Creset%ad %C(blue)%an %Creset%s" \
			--date=short \
			--reverse
		
	fi
}

function wbd {
	if [ "$1" == "" ] || [ "$2" == "" ];
	then
		echo "Command: What been doing?"
		echo "ERR: Arguments <since> and <author> are both required."
		echo ""
		exit 1
	fi

	git log --since $1 --pretty=format:"%C(yellow)%h %Creset%an %ad %s" \
		--date=short --author $2
}

function show_help {
	echo "gitmine 0.1"
	echo "Usage: gitmine <command> [<args>]"
	echo ""
	echo "Common commands:"
	# working
	echo "   cmts  <since> <until> [author]   Show commits since/until."
	echo "   wbd   <since> <author>           What been doing?"
	echo "   cmpf  [author]                   Commits per file."
	echo "   hi    <filename>                 Commits count per file."
	echo "   score                            Global commit count per author."
	# FIXME!!!
	echo "   refc  <filename>                 Count class references."
	echo ""
}

export -f find_classes
export -f ref_count
export -f find_and_count
export -f missing_name
export -f invalid_op
export -f print_score
export -f wbd
export -f commits_per_file
export -f hi
export -f show_help
export -f commits_since_until

if [[ "$1" == "cmpf" ]]; then
	commits_per_file "$2"
elif [[ "$1" == "wbd" ]]; then
	wbd "$2" "$3"
elif [[ "$1" == "cmts" ]]; then
	commits_since_until "$2" "$3" "$4"
elif [[ "$1" == "score" ]]; then
	# Global count. 
	# All authors, all files.
	hi
elif [[ "$1" == "hi" ]]; then
	# Counts commits per file. 
	# All authors, ONE file.
	if [ "$2" == "" ]; then
		echo "The parameter <file> is required for this command.";
		exit 1
	fi
	hi "$2"
elif [[ "$1" == "pwd" ]]; then # <- This one is for debugging purposes.
	pwd
	exit
elif [[ "$1" == "refc" ]]; then
	dir="$(pwd)"
	ref_count "$dir" "'$2'"    # <- $2 MUST be quoted to avoid path expansion.
else
	show_help
fi
