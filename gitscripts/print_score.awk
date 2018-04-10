# Prints a commits score board.
{ names[$1] +=1; };
END {
	for (n in names) printf("%7d | %s\n", names[n], n); 
};
