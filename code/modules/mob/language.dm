/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"            // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims" // Used when sentence ends in a !
	var/signlang_verb = list()       // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	var/colour = "body"         // CSS style to use for strings in this language.
	var/list/key = list("x")                    // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                    // Various language flags.
	var/native                       // If set, non-native speakers will have trouble speaking.
	var/list/syllables               // Used when scrambling text for a non-speaker.
	var/list/space_chance = 55 // Likelihood of getting a space in the random scramble string.
	var/list/allowed_species	 // A name of species, Which can use this lang as secondary.

/datum/language/proc/color_message(message)
	return "<span class='message'><span class='[colour]'>[capitalize(message)]</span></span>"

/datum/language/proc/format_message(message, verb)
	return "[verb], <span class='message'><span class='[colour]'>\"[capitalize(message)]\"</span></span>"

/datum/language/proc/format_message_radio(message, verb)
	return "[verb], <span class='[colour]'>\"[capitalize(message)]\"</span>"

/datum/language/proc/scramble(input)

	if(!syllables || !syllables.len)
		return stars(input)

	var/input_size = length_char(input)
	var/scrambled_text = ""

	for(var/i in 1 to input_size)
		scrambled_text += pick(syllables)
		
		if(i != input_size)
			if(prob(5))
				scrambled_text += ", "
			else if(prob(space_chance))
				scrambled_text += " "
	
	scrambled_text = capitalize(trim(scrambled_text))

	var/input_ending = copytext(input, -1)
	if(input_ending in list("!","?","."))
		scrambled_text += input_ending
	
	return scrambled_text

/datum/language/proc/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return exclaim_verb
		if("?")
			return ask_verb
	return speech_verb

/datum/language/unathi
	name = "Sinta'unathi"
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "roars"
	colour = "soghun"
	key = list("o", "щ")
	allowed_species = list(IPC)
	syllables = list("ss","ss","ss","ss","skak","seeki","resh","las","esi","kor","sh")

/datum/language/tajaran
	name = "Siik'maas"
	desc = "The traditionally employed tongue of Ahdomai, composed of expressive yowls and chirps. Native to the Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verb = "yowls"
	colour = "tajaran"
	allowed_species = list(IPC)
	key = list("j", "о")
	syllables = list("rr","rr","tajr","kir","raj","kii","mir","kra","ahk","nal","vah","khaz","jri","ran","darr", \
	"mi","jri","dynh","manq","rhe","zar","rrhaz","kal","chur","eech","thaa","dra","jurl","mah","sanu","dra","ii'r", \
	"ka","aasi","far","wa","baq","ara","qara","zir","sam","mak","hrar","nja","rir","khan","jun","dar","rik","kah", \
	"hal","ket","jurl","mah","tul","cresh","azu","ragh")

/datum/language/tajaran_sign
	name = "Siik'tajr"
	desc = "An expressive language that combines yowls and chirps with posture, tail and ears. Spoken by many Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verb = "yowls"
	colour = "tajaran_signlang"
	key = list("y", "н")
	signlang_verb = list("flicks their left ear", "flicks their right ear", "swivels their ears", "twitches their tail", "curls the end of their tail", "arches their tail", "wiggles the end of their tail", "waves their tail about", "holds up a claw", "gestures with their left hand", "gestures with their right hand", "gestures with their tail", "gestures with their ears")
	flags = NONVERBAL

/datum/language/skrell
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verb = "warbles"
	colour = "skrell"
	key = list("k", "л")
	allowed_species = list(IPC)
	syllables = list("qr","qrr","xuq","qil","quum","xuqm","vol","xrim","zaoo","qu-uu","qix","qoo","zix","*","!")

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	ask_verb = "creels"
	exclaim_verb = "SHRIEKS"
	colour = "vox"
	key = list("v", "м")
	flags = RESTRICTED
	syllables = list("ti","ti","ti","hi","hi","ki","ki","ki","ki","ya","ta","ha","ka","ya","chi","cha","kah", \
	"SKRE","AHK","EHK","RAWK","KRA","AAA","EEE","KI","II","KRI","KA")

/datum/language/diona
	name = "Rootspeak"
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	ask_verb = "creaks"
	exclaim_verb = "rustles"
	allowed_species = list(IPC)
	colour = "soghun"
	key = list("q", "й")
	syllables = list("hs","zt","kr","st","sh")

/datum/language/diona_space
	name = "Rootsong"
	desc = "A language represented by series of high frequency waves, similiar to those of radio waves. Can not be picked up without advanced equipment, but waves do spread in space."
	allowed_species = list(IPC, DIONA)
	colour = "soghun"
	key = list("f", "а")
	signlang_verb = list("emits a series of short beeps", "screeches in boops", "eminates short pings", "projects a series of screeches")
	flags = SIGNLANG // For all intents and purposes, this is basically a sign language.

/datum/language/human
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	colour = "rough"
	key = list("1")
	allowed_species = list(IPC, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	syllables = list("tao","shi","tzu","yi","com","be","is","i","op","vi","ed","lec","mo","cle","te","dis","e")

/datum/language/ipc
	name = "Trinary"
	desc = "A modified binary fuzzy logic based language spoken by IPC. Basically, is just a sequence of zeros, ones and twos."
	speech_verb = "pings"
	ask_verb = "beeps"
	exclaim_verb = "boops"
	colour = "ipc"
	key = list("x", "ч") //only "dpz" left.
	//need to find a way to resolve possesive macros
	allowed_species = list(IPC)
	syllables = list("000", "111", "222", "001", "010", "100", "002", "020", "200", "011", "101", "110", "022", "202", "220", "112", "121", "211", "122", "212", "221", "012", "021", "120", "210", "102", "201")

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "say_quote"
	key = list("2")
	allowed_species = list(IPC, HUMAN, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	syllables = list("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
					 "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
					 "magna", "aliqua", "ut", "enim", "ad", "minim", "veniam", "quis", "nostrud",
					 "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo",
					 "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in",
					 "voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla",
					 "pariatur", "excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt",
					 "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum")

/datum/language/gutter
	name = "Gutter"
	desc = "Much like Standard, this crude pidgin tongue descended from numerous languages and serves as Tradeband for criminal elements."
	speech_verb = "growls"
	colour = "rough"
	key = list("3")
	allowed_species = list(IPC, HUMAN, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	syllables = list ("gra","ba","ba","breh","bra","rah","dur","ra","ro","gro","go","ber","bar","geh","heh", "gra")


/datum/language/syndi
	name = "Sy-Code"
	desc = "Constructed language, used by syndicate agents and operatives. Consists of NATO alphabet and booze. The definition of each syllable is predetermined by current operation."
	speech_verb = "signals"
	colour = "syndcode"
	key = list("0")
	syllables = list ("alpha","bravo","charlie","delta","echo","foxtrot","golf","hotel","india","juliett","kilo","lima","mike","november","oscar",
					  "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey", "xray", "yankee", "zulu",
					  "nadazero", "unaone", "bissatwo", "terrathree", "kartefour", "pantafive", "soxisix", "setteseven", "oktoeight", "novenine",
					  "ale", "cognac", "kahlua", "soda", "tequila", "vermouth", "whiskey", "beer", "gin", "rum", "lemon lime", "vodka", "wine")
	flags = RESTRICTED
	space_chance = 100

/datum/language/unisign
	name = "Universal Sign Language"
	desc = "Standart language made of gestures. Common language of deaf and muted people."
	colour = "rough"
	key = list("4")
	allowed_species = list(IPC, HUMAN, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	signlang_verb = list("makes signs with hands", "gestures", "waves hands", "gesticulates")
	flags = SIGNLANG


// Language handling.
/mob/proc/add_language(language)

	var/datum/language/new_language = all_languages[language]

	if(!istype(new_language) || (new_language in languages))
		return 0

	languages.Add(new_language)
	return 1

/mob/proc/remove_language(rem_language)

	languages.Remove(all_languages[rem_language])

	return 0

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak(datum/language/speaking)

	return (universal_speak || (speaking in src.languages))

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] "
		for(var/l_key in L.key)
			dat += "(:[l_key])"
		dat += " </b><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return
