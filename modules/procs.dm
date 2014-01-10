/proc/random_color()
	var/list/rand = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")
	return "#" + pick(rand) + pick(rand) + pick(rand) + pick(rand) + pick(rand) + pick(rand)

/proc/count_occurrences(string, substring)
	var/count = 0
	var/found = 0
	var/length = length(substring)

	found = findtext(string, substring)

	while(found)
		count++
		found += length
		found = findtext(string, substring, found)

	return count