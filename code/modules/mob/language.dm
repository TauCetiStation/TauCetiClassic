/*
	Datum based languages. Easily editable and modular.
*/

#define MESSAGE_LIMIT 20

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"            // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims" // Used when sentence ends in a !
	var/signlang_verb = list()       // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	var/colour = "body"         // CSS style to use for strings in this language.
	var/list/key = list()                    // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                    // Various language flags.
	var/list/syllables               // Used when scrambling text for a non-speaker.
	var/list/space_chance = 55 // Likelihood of getting a space in the random scramble string.

	// Symbols(sounds) exclusively available to (native speakers) of this language, and their approximations for those who can't pronounce them
	var/list/approximations
	// Special symbol combinations to produce exclusive to native speakers sounds.
	var/list/special_symbols
	// Approximations, but which carriers of the language produce when not speaking in this language.
	var/list/accents

	// Names of species in both of these.
	// What species can understand but can't speak
	// var/list/allowed_understand
	// What species can speak(and thus understand). Is used in loadout language choosing.
	var/list/allowed_speak

/datum/language/Topic(href, href_list)
	var/mob/M = locate(href_list["usr"])
	if(!istype(M))
		return

	// Can't speak and not native.
	if(M.languages[src] == LANGUAGE_CAN_UNDERSTAND)
		return

	if(M.default_language == name)
		// Please make Galactic Common a language one day? ~Luduk
		to_chat(M, "<span class='notice'>Now speaking in Galactic Common by default.</span>")
		M.default_language = null
		M.check_languages()
		return

	to_chat(M, "<span class='notice'>Now speaking in [name] by default.</span>")
	M.default_language = name
	M.check_languages()

/datum/language/proc/color_message(message)
	return "<span class='message'><span class='[colour]'>[capitalize(message)]</span></span>"

/datum/language/proc/format_message(message, verb)
	return "[verb], <span class='message'><span class='[colour]'>\"[capitalize(message)]\"</span></span>"

/datum/language/proc/format_message_radio(message, verb)
	return "[verb], <span class='[colour]'>\"[capitalize(message)]\"</span>"

// How the bearer of this language pronounces stuff in their non-native language.
/datum/language/proc/accentuate(input, datum/language/speaking)
	if(!accents)
		return input
	return replace_characters(input, accents)

/datum/language/proc/scramble(input)

	if(!syllables || !syllables.len)
		return stars(input)

	var/input_size = length_char(input)
	var/scrambled_text = ""

	if(input_size > MESSAGE_LIMIT)
		input_size = MESSAGE_LIMIT	//limitation on abracadabra

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
	name = LANGUAGE_SINTAUNATHI
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "roars"
	colour = "soghun"
	key = list("o", "щ")
	syllables = list("çs","ss","ss","ꚗs","skak","seeki","resh","las","esi","kor","sh")
	approximations = list(
		"ç" = "с",
		"ꚗ" = "ш",
	)
	special_symbols = list(
		"*С" = "Ç",
		"*с" = "ç",
		"*Ш" = "Ꚗ",
		"*ш" = "ꚗ",
	)
	accents = list(
		"с" = "сс",
	)
	allowed_speak = list(IPC)

/datum/language/tajaran
	name = LANGUAGE_SIIKMAAS
	desc = "The traditionally employed tongue of Ahdomai, composed of expressive yowls and chirps. Native to the Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verb = "yowls"
	colour = "tajaran"
	allowed_speak = list(IPC)
	key = list("j", "о")
	syllables = list("rr","rr","tajr","kir","raj","kii","mir","kra","ahk","nal","vah","khaz","jri","ran","darr", \
	"mi","jri","dynh","manq","rhe","zar","rrhaz","kal","chur","eech","thaa","dra","jurl","mæh","sænu","dra","ii'r", \
	"ka","aasi","far","wa","baq","ara","qara","zir","sam","mæk","hrar","nja","rir","khan","jun","dar","rik","kah", \
	"hal","kət","jurl","mah","tul","cresh","azu","ragh")
	approximations = list(
		"æ" = "ae",
		"ə" = "e",
	)
	special_symbols = list(
		"*А" = "Æ",
		"*а" = "æ",
		"*Е" = "Ə",
		"*е" = "ə",
	)
	accents = list(
		"р" = "рр",
	)

/datum/language/tajaran/accentuate(input, datum/language/speaking)
	if(speaking && speaking.name == LANGUAGE_SIIKTAJR)
		return input
	return ..()

/datum/language/tajaran_sign
	name = LANGUAGE_SIIKTAJR
	desc = "An expressive language that combines yowls and chirps with posture, tail and ears. Spoken by many Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verb = "yowls"
	colour = "tajaran_signlang"
	key = list("y", "н")
	signlang_verb = list("flicks their left ear", "flicks their right ear", "swivels their ears", "twitches their tail", "curls the end of their tail", "arches their tail", "wiggles the end of their tail", "waves their tail about", "holds up a claw", "gestures with their left hand", "gestures with their right hand", "gestures with their tail", "gestures with their ears")
	flags = NONVERBAL

/datum/language/skrell
	name = LANGUAGE_SKRELLIAN
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verb = "warbles"
	colour = "skrell"
	key = list("k", "л")
	allowed_speak = list(IPC)
	syllables = list("qr","qrr","xuq","qil","quun","xuqn","rol","xrin","zaoo","qu-uu","qix","qoo","zix","*","!","♭","♮","♯")

/datum/language/vox
	name = LANGUAGE_VOXPIDGIN
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	ask_verb = "creels"
	exclaim_verb = "SHRIEKS"
	colour = "vox"
	key = list("v", "м")
	syllables = list("ti","ti","ti","hi","hi","ki","ki","ki","ki","ya","ta","ha","ka","ya","chi","cha","kah", \
	"SKRE","AHK","EHK","RAWK","KRA","AAA","EEE","KI","II","KRI","KA")
	allowed_speak = list(IPC)

/datum/language/diona
	name = LANGUAGE_ROOTSPEAK
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	ask_verb = "creaks"
	exclaim_verb = "rustles"
	allowed_speak = list(IPC)
	colour = "soghun"
	key = list("q", "й")
	syllables = list("hs","zt","kr","st","sh")

/datum/language/diona_space
	name = LANGUAGE_ROOTSONG
	desc = "A language represented by series of high frequency waves, similiar to those of radio waves. Can not be picked up without advanced equipment, but waves do spread in space."
	allowed_speak = list(IPC, DIONA)
	colour = "soghun"
	key = list("f", "а")
	signlang_verb = list("emits a series of short beeps", "screeches in boops", "eminates short pings", "projects a series of screeches")
	flags = SIGNLANG // For all intents and purposes, this is basically a sign language.

/datum/language/human
	name = LANGUAGE_SOLCOMMON
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	colour = "rough"
	key = list("1")
	allowed_speak = list(IPC, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	syllables = list("tao","shi","tzu","yi","com","be","is","i","op","vi","ed","lec","mo","cle","te","dis","e")

/datum/language/ipc
	name = LANGUAGE_TRINARY
	desc = "A modified binary fuzzy logic based language spoken by IPC. Basically, is just a sequence of zeros, ones and twos."
	speech_verb = "pings"
	ask_verb = "beeps"
	exclaim_verb = "boops"
	colour = "ipc"
	key = list("p", "з")
	syllables = list("000", "111", "222", "001", "010", "100", "002", "020", "200", "011", "101", "110", "022", "202", "220", "112", "121", "211", "122", "212", "221", "012", "021", "120", "210", "102", "201")

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = LANGUAGE_TRADEBAND
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "say_quote"
	key = list("2")
	allowed_speak = list(IPC, HUMAN, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	syllables = list("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
					 "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
					 "magna", "aliqua", "ut", "enim", "ad", "minim", "veniam", "quis", "nostrud",
					 "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo",
					 "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in",
					 "voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla",
					 "pariatur", "excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt",
					 "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum")
	accents = list(
		"ё" = "ю",
	)

/datum/language/gutter
	name = LANGUAGE_GUTTER
	desc = "Much like Standard, this crude pidgin tongue descended from numerous languages and serves as Tradeband for criminal elements."
	speech_verb = "growls"
	colour = "rough"
	key = list("3")
	allowed_speak = list(IPC, HUMAN, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	syllables = list ("gra","ba","ba","breg","bra","rag","dur","ra","ro","gro","go","ber","bar","geg","gra")
	accents = list(
		"х" = "г",
	)

/datum/language/syndi
	name = LANGUAGE_SYCODE
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
	name = LANGUAGE_USL
	desc = "Standart language made of gestures. Common language of deaf and muted people."
	colour = "rough"
	key = list("4")
	allowed_speak = list(IPC, HUMAN, DIONA, SKRELL, UNATHI, TAJARAN, VOX)
	signlang_verb = list("makes signs with hands", "gestures", "waves hands", "gesticulates")
	flags = SIGNLANG

/datum/language/xenomorph
	name = LANGUAGE_XENOMORPH
	desc = "Xenomorph language."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "hisses"
	colour = "alien"
	syllables = list("сс", "хсс", "ссс", "щсс", "щсхх", "ссс", "сс")
	flags = RESTRICTED

/datum/language/shkiondioniovioion
	name = LANGUAGE_SHKIONDIONIOVIOION
	desc = "Ёn ёncёёnt, fёrgёttёn lёngёёgё, ёt's rёёts stёm frёm tёmё ёmmёmёrёёl."
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "exclaims"
	colour = "body"
	key = list("`", "ё")
	syllables = list("ёх", "ёс", "ёс", "ём", "ён", "бён", "вёл", "гёр", "мёг", "трё", "лёс", "рёйд", "ё", "мём", "ёнт")

	var/list/replacements

/datum/language/shkiondioniovioion/New()
	var/list/lowercase_vowels = list()

	for(var/vowel in ENGLISH_VOWELS)
		lowercase_vowels += vowel

	var/list/ru_vowels = RUSSIAN_VOWELS
	// Define problems
	ru_vowels = ru_vowels.Copy()
	ru_vowels.Remove("ё")

	for(var/vowel in ru_vowels)
		lowercase_vowels += vowel

	replacements = list()
	for(var/vowel in lowercase_vowels)
		replacements[vowel] = "ё"

/datum/language/shkiondioniovioion/scramble(input)
	return replace_characters(input, replacements)

/datum/language/salackyi
	name = LANGUAGE_SALACKYI
	desc = "One of the most prominent space-slavic languages out there. Consists of many funny sounds, as well as deep, melodic structure."
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "exclaims"
	colour = "body"
	key = list("x", "ч")
	syllables = list("на", "ня", "ні", "нає", "ма", "мі", "та", "тя", "ко", "нко", "ля", "ла", "ша", "шо", "ха", "хо", "хи", "ги", "ґи", "юк", "як")

	approximations = list(
		"і" = "и",
	)

	var/list/replacements

/datum/language/salackyi/New()
	var/list/lowercase_letters = list(
		"и" = "і",
		"ы" = "и",
		"э" = "е",
		"е" = "є",
		"ё" = "йо",
		"г" = "ґ",
		"чт" = "ш",
	)

	replacements = list()
	for(var/letter in lowercase_letters)
		var/replacement = lowercase_letters[letter]
		replacements[letter] = replacement

/datum/language/salackyi/scramble(input)
	return replace_characters(input, replacements)

// Language handling.
/mob/proc/add_language(language, flags=LANGUAGE_CAN_SPEAK)
	if(isnull(flags))
		flags = LANGUAGE_CAN_SPEAK

	var/datum/language/new_language = all_languages[language]
	if(!new_language)
		return FALSE

	if((new_language in languages) && languages[new_language] >= flags)
		return FALSE

	if(flags != LANGUAGE_CAN_UNDERSTAND)
		for(var/sound in new_language.approximations)
			remove_approximation(sound)

		for(var/sound in new_language.special_symbols)
			add_approximation(sound, new_language.special_symbols[sound], case_sensitive=TRUE)

	languages[new_language] = flags
	return TRUE

/mob/proc/remove_language(language, flags)
	var/datum/language/L = all_languages[language]
	if(!L)
		return FALSE

	if(languages[L] != LANGUAGE_CAN_UNDERSTAND)
		for(var/sound in L.approximations)
			add_approximation(sound, L.approximations[sound])

		for(var/sound in L.special_symbols)
			remove_approximation(sound, case_sensitive=TRUE)

	languages.Remove(L)

	if(default_language == L.name)
		default_language = null

	return TRUE

/mob/proc/can_understand(datum/language/speaking)
	return universal_understand || (speaking in languages)

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak(datum/language/speaking)
	if(universal_speak)
		return TRUE

	if(!languages)
		return FALSE

	return languages[speaking] >= LANGUAGE_CAN_SPEAK

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = ""

	for(var/datum/language/L in languages)
		var/lang_name = L.name
		var/link_class = ""
		if(L.name == default_language)
			link_class = "class='good'"

		if(languages[L] != LANGUAGE_CAN_UNDERSTAND)
			lang_name = "<a href='?src=\ref[L];usr=\ref[src]'[link_class]>[lang_name]</a>"

		dat += "<b>[lang_name] "
		for(var/l_key in L.key)
			dat += "(:[l_key])"

		if(languages[L] != LANGUAGE_CAN_UNDERSTAND)
			var/sound_macros = ""
			var/first_macro = TRUE
			for(var/m_key in L.special_symbols)
				if(m_key == uppertext(m_key))
					continue
				if(!first_macro)
					sound_macros += ", "
				first_macro = FALSE
				sound_macros += "[m_key]"

			if(sound_macros != "")
				dat += " ([sound_macros])"

		var/remark = ""
		if(languages[L] == LANGUAGE_CAN_UNDERSTAND)
			remark += " <i>(can't speak)</i>"

		dat += " </b><br/>[L.desc][remark]<br/><br/>"

	var/datum/browser/popup = new(src, "checklanguage", "Known Languages")
	popup.set_content(dat)
	popup.open()

#undef MESSAGE_LIMIT
