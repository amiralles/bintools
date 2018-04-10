function print_score {
	awk "{ names[\$1] +=1; };END { for (n in names) printf(\"%7d | %s\n\", names[n], n); };"
}

export -f print_score

fname="$1"
echo ""
echo "Commits | Author"
git log --pretty=format:"%an" -- $fname | print_score | sort -nr
echo ""
echo ""
