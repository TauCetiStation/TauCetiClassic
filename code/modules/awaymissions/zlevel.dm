/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var! //todo: need new var for this
		return

	var/list/potentialRandomZlevels = list()
	to_chat(world, "<span class='warning'><b>Searching for away missions...</b></span>")
	var/list/Lines = file2list("maps/RandomZLevels/fileList.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
            // No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		else
            // No, don't do lowertext here, that breaks paths on linux
			name = t

		if (!name)
			continue

		potentialRandomZlevels.Add(name)


	if(potentialRandomZlevels.len)
		to_chat(world, "<span class='warning'><b>Loading away mission...</b></span>")

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file)

		to_chat(world, "<span class='warning'><b>Away mission loaded.</b></span>")

	else
		to_chat(world, "<span class='warning'><b>No away missions found.</b></span>")
		return
