var/global/church_name = null
/proc/church_name()
	if (church_name)
		return church_name

	var/name = ""

	name += pick("Holy", "United", "First", "Second", "Last")

	if (prob(20))
		name += " Space"

	name += " " + pick("Church", "Cathedral", "Body", "Worshippers", "Movement", "Witnesses")
	name += " of [religion_name()]"

	return name

var/global/command_name = null
/proc/command_name()
	if (command_name)
		return command_name

	var/name = "Central Command"

	command_name = name
	return name

/proc/change_command_name(name)

	command_name = name

	return name

var/global/religion_name = null
/proc/religion_name()
	if (religion_name)
		return religion_name

	var/name = ""

	name += pick("bee", "science", "edu", "captain", "assistant", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "goon", "robot", "ivor", "hobnob")
	name += pick("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")

	return capitalize(name)

/proc/system_name()
	if(system_name)
		return system_name

	return "Tau Ceti" //Screw Nyx

/proc/system_name_ru()
	if(system_name_ru)
		return system_name_ru
	return system_name()

/proc/station_name()
	if (station_name)
		return station_name

	station_name = new_station_name()

	if (config && config.server_name)
		world.name = "[config.server_name]: [station_name]"
	else
		world.name = station_name

	return station_name

/proc/station_name_ru()
	if (station_name_ru)
		return station_name_ru
	return station_name()

/proc/new_station_name()
	var/random = rand(1,5)
	var/name = ""
	var/return_name = ""

	//Rare: Pre-Prefix
	if (prob(10))
		name = pick("Imperium", "Heretical", "Cuban", "Psychic", "Elegant", "Common", "Uncommon", "Rare", "Unique", "Houseruled", "Religious", "Atheist", "Traditional", "Houseruled", "Mad", "Super", "Ultra", "Secret", "Top Secret", "Deep", "Death", "Zybourne", "Central", "Main", "Government", "Uoi", "Fat", "Automated", "Experimental", "Augmented")
		return_name = name + " "

	// Prefix
	for(var/holiday_name in SSholiday.holidays)
		if(holiday_name == "Friday the 13th")
			random = 13
		var/datum/holiday/holiday = SSholiday.holidays[holiday_name]
		name = holiday.getStationPrefix()

	//get normal name
	if(!name)
		name = pick("", "Stanford", "Dorf", "Alium", "Prefix", "Clowning", "Aegis", "Ishimura", "Scaredy", "Death-World", "Mime", "Honk", "Rogue", "MacRagge", "Ultrameens", "Safety", "Paranoia", "Explosive", "Neckbear", "Donk", "Muppet", "North", "West", "East", "South", "Slant-ways", "Widdershins", "Rimward", "Expensive", "Procreatory", "Imperial", "Unidentified", "Immoral", "Carp", "Ork", "Pete", "Control", "Nettle", "Aspie", "Class", "Crab", "Fist","Corrogated","Skeleton","Race", "Fatguy", "Gentleman", "Capitalist", "Communist", "Bear", "Beard", "Derp", "Space", "Spess", "Star", "Moon", "System", "Mining", "Neckbeard", "Research", "Supply", "Military", "Orbital", "Battle", "Science", "Asteroid", "Home", "Production", "Transport", "Delivery", "Extraplanetary", "Orbital", "Correctional", "Robot", "Hats", "Pizza")
	if(name)
		return_name += name + " "

	// Suffix
	name = pick("Station", "Fortress", "Frontier", "Suffix", "Death-trap", "Space-hulk", "Lab", "Hazard","Spess Junk", "Fishery", "No-Moon", "Tomb", "Crypt", "Hut", "Monkey", "Bomb", "Trade Post", "Fortress", "Village", "Town", "City", "Edition", "Hive", "Complex", "Base", "Facility", "Depot", "Outpost", "Installation", "Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform", "Construct", "Hangar", "Prison", "Center", "Port", "Waystation", "Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object", "Fortification", "Colony", "Planet-Cracker", "Roost", "Fat Camp")
	return_name += name + " "

	// ID Number
	switch(random)
		if(1)
			return_name += "[rand(1, 99)]"
		if(2)
			return_name += pick("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
		if(3)
			return_name += pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")
		if(4)
			return_name += pick("Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu")
		if(5)
			return_name += pick("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen")
		if(13)
			return_name += pick("13","XIII","Thirteen")

	return return_name

/proc/world_name(name)

	station_name = name

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return name

var/global/syndicate_name = null
/proc/syndicate_name()
	if (syndicate_name)
		return syndicate_name

	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	syndicate_name = name
	return name

//Traitors and traitor silicons will get these. Revs will not.
var/global/list/syndicate_code_phrase = list() //Code phrase for traitors.
var/global/list/syndicate_code_response = list() //Code response for traitors.
var/global/regex/code_phrase_highlight_rule
var/global/regex/code_response_highlight_rule

	/*
	Should be expanded.
	How this works:
	Instead of "I'm looking for James Smith," the traitor would say "James Smith" as part of a conversation.
	Another traitor may then respond with: "They enjoy running through the void-filled vacuum of the derelict."
	The phrase should then have the words: James Smith.
	The response should then have the words: run, void, and derelict.
	This way assures that the code is suited to the conversation and is unpredicatable.
	Obviously, some people will be better at this than others but in theory, everyone should be able to do it and it only enhances roleplay.
	Can probably be done through "{ }" but I don't really see the practical benefit.
	One example of an earlier system is commented below.
	*/

/proc/set_languge_lists()
	global.rus_nouns = file2list("config/names/rus_nouns.txt")
	global.rus_adjectives = file2list("config/names/rus_adjectives.txt")
	global.rus_verbs = file2list("config/names/rus_verbs.txt")
	global.rus_occupations = file2list("config/names/rus_occupations.txt")
	global.rus_bays = file2list("config/names/rus_bays.txt")
	global.rus_local_terms = file2list("config/names/rus_local_terms.txt")

//Proc is used for phrase and response in subsystem init.
/proc/generate_code_phrase()
	//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
	set_languge_lists()
	var/words_count = pick(
		50; 2,
		200; 3,
		50; 4,
		25; 5
	)
	var/code_phrase[words_count]
	for(var/i in 1 to code_phrase.len)
		var/word = pick(
				80; pick(global.rus_occupations),
				70; pick(global.rus_bays),
				65; pick(global.rus_local_terms),
				65; pick(global.rus_adjectives),
				55; pick(global.rus_nouns),
				40; pick(global.rus_verbs)
			)

		if(!word || code_phrase.Find(word, 1, i)) // Reroll duplicates and errors
			i--
			continue

		var/separator_position = findtext(word, "|")
		code_phrase[i] = copytext(word, 1, separator_position) // Word's root
		code_phrase[code_phrase[i]] = separator_position == length(word) ? "" : copytext(word, separator_position + 1) // Associated ending

	return code_phrase

/proc/generate_code_regex(list/words, ending_chars)
	return regex("(^|\[^[ending_chars]])((?:[jointext(words,  "|")])\[[ending_chars]]{0,3})(?:(?!\[[ending_chars]]))", "ig")

/proc/highlight_codewords(t, regex/rule, css_class = "notice")
	if(!rule)
		return t
	return rule.Replace(t, "$1<span class='[css_class]'>$2</span>")

/proc/codewords2string(list/codewords)
	ASSERT(islist(codewords))
	for(var/i in 1 to codewords.len)
		. += "<span class='danger'>[codewords[i]]</span>"
		if (codewords[codewords[i]])
			. += "(-[codewords[codewords[i]]])"
		. += i != codewords.len ? ", " : "."
	return

/proc/highlight_traitor_codewords(message, datum/mind/traitor_mind)
	if(!traitor_mind)
		return message

	var/awareness = 0
	for(var/role in traitor_mind.antag_roles)
		var/datum/role/R = traitor_mind.antag_roles[role]
		var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
		if(!S)
			continue
		if(S.syndicate_awareness > awareness)
			awareness = S.syndicate_awareness

	if(!awareness)
		return message

	switch(awareness)
		if(SYNDICATE_AWARE)
			message = highlight_codewords(message, global.code_phrase_highlight_rule) // Same can be done with code_response or any other list of words, using regex created by generate_code_regex(). You can also add the name of CSS class as argument to change highlight style.
			message = highlight_codewords(message, global.code_response_highlight_rule, "deptradio")

		if(SYNDICATE_PHRASES)
			message = highlight_codewords(message, global.code_phrase_highlight_rule)

		if(SYNDICATE_RESPONSE)
			message = highlight_codewords(message, global.code_response_highlight_rule, "deptradio")

	return message
