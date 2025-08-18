//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 8

//This is the current version, anything below this will attempt to update (if it's not obsolete)

#define SAVEFILE_VERSION_MAX 56

//For repetitive updates, should be the same or below SAVEFILE_VERSION_MAX
//set this to (current SAVEFILE_VERSION_MAX)+1 when you need to update:
#define SAVEFILE_VERSION_SPECIES_JOBS 51 // job preferences after breaking changes to any /datum/job/
#define SAVEFILE_VERSION_QUIRKS 30 // quirks preferences after breaking changes to any /datum/quirk/
//breaking changes is when you remove any existing quirk/job or change their restrictions
//Don't forget to bump SAVEFILE_VERSION_MAX too

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)
	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)
	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.
	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/

#define SAVEFILE_UP_TO_DATE -1 // everything is okay, nothing to update.
#define SAVEFILE_TOO_OLD    -2 // savefile is too old, all data will be wiped.

/datum/preferences/proc/savefile_needs_update(savefile/S)
	S["version"] >> savefile_version

	if(isnull(savefile_version)) // By the time this feature added, we don't have separate "version" value for characters, so let's set it.
		savefile_version = 8     // Don't touch this magic number.

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return SAVEFILE_TOO_OLD

	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version

	return SAVEFILE_UP_TO_DATE

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	/* JUST AN EXAMPLE for future updates.
	if(current_version < 10)
		toggles |= MEMBER_PUBLIC
	*/
	if(current_version < 15)
		S["warns"]    << null
		S["warnbans"] << null

	if(current_version < 16)
		S["aooccolor"] << S["ooccolor"]
		aooccolor = ooccolor

	if(current_version < 25)
		var/const/SOUND_ADMINHELP = 1
		var/const/SOUND_MIDI = 2
		var/const/SOUND_AMBIENCE = 4
		var/const/SOUND_LOBBY = 8
		var/const/SOUND_STREAMING = 64

		toggles &= ~(SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_STREAMING)
		S["toggles"] << toggles

	if(current_version < 26)
		for(var/role in be_role)
			if(!CanBeRole(role))
				be_role -= role

	if(current_version < 44)
		custom_emote_panel = global.emotes_for_emote_panel

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 17)
		for(var/organ_name in organ_data)
			if(organ_name in list("r_hand", "l_hand", "r_foot", "l_foot"))
				organ_data -= organ_name
				S["organ_data"] -= organ_name

	if(current_version < 18)
		popup(parent, "Your character([real_name]) had old job preferences, probably incompatible with current version. Your job preferences have been reset.", "Preferences")
		ResetJobs()
		S["job_preferences"]	<< job_preferences

		if(language && species && language != "None")
			if(!istext(language))
				var/atom/A = language
				language = A.name

			var/datum/language/lang = all_languages[language]
			if(!(species in lang.allowed_speak))
				language = "None"
				S["language"] << language

	if(current_version < 21)
		S["disabilities"] << null

		all_quirks = list()
		positive_quirks = list()
		negative_quirks = list()
		neutral_quirks = list()

		S["all_quirks"] << all_quirks
		S["positive_quirks"] << positive_quirks
		S["negative_quirks"] << negative_quirks
		S["neutral_quirks"]  << neutral_quirks

	if(current_version < 23)
		var/datum/job/assistant/J = new

		if(player_alt_titles && \
			(player_alt_titles[J.title] in list("Technical Assistant", "Medical Intern", "Research Assistant", "Security Cadet")))

			player_alt_titles -= J.title

	if(current_version < 27)
		// before there was migration for old job preferences but we dropped it
		// 5 years is enough
		job_preferences = list() //It loaded null from nonexistant savefile field.
		S["job_preferences"] << job_preferences

	if(current_version < 28)
		//This is necessary so that old players remove unnecessary roles
		//and automatically set the preference "ROLE_GHOSTLY"
		var/role_removed = FALSE
		var/static/list/deleted_selectable_roles = list("pAI", "Diona", "Survivor", "Talking staff", "Religion familiar")
		for(var/role in deleted_selectable_roles)
			if(role in be_role)
				be_role -= role
				role_removed = TRUE

		if(role_removed)
			be_role |= ROLE_GHOSTLY

		S["be_role"] << be_role

	if(current_version < 31)
		flavor_text = fix_cyrillic(flavor_text)
		med_record  = fix_cyrillic(med_record)
		sec_record  = fix_cyrillic(sec_record)
		gen_record  = fix_cyrillic(gen_record)
		metadata    = fix_cyrillic(metadata)
		home_system = fix_cyrillic(home_system)
		citizenship = fix_cyrillic(citizenship)
		faction     = fix_cyrillic(faction)
		religion    = fix_cyrillic(religion)

		S["flavor_text"] << flavor_text
		S["med_record"]  << med_record
		S["sec_record"]  << sec_record
		S["gen_record"]  << gen_record
		S["OOC_Notes"]   << metadata
		S["home_system"] << home_system
		S["citizenship"] << citizenship
		S["faction"]     << faction
		S["religion"]    << religion

	if(current_version < 32)
		popup(parent, "Части тела вашего персонажа ([real_name]) несовместимы с текущей версией. Части тела данного персонажа восстановлены до обычного состояния.", "Preferences")
		organ_data = list()
		for(var/i in list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM, O_HEART, O_EYES))
			organ_data[i] = null

	if(current_version < 33)
		S["parallax_theme"] << null

	if(current_version < 36)
		var/datum/job/assistant/J = new

		if(player_alt_titles && (player_alt_titles[J.title] in list("Mecha Operator")))
			player_alt_titles -= J.title

	if(current_version < 37)
		var/list/deleted_hairstyles = list("Skrell Long Female Tentacles", "Skrell Zeke Female Tentacles", "Gold plated Skrell Male Tentacles", "Gold chained Skrell Female Tentacles", "Cloth draped Skrell Male Tentacles", "Cloth draped Skrell Female Tentacles")
		if(h_style in deleted_hairstyles)
			h_style = "Skrell Long Tentacles"

	if(current_version < 38)
		if("Raider" in be_role)
			be_role -= "Raider"

		S["be_role"] << be_role

	if(current_version < 39)
		S["ghost_orbit"] << null

	if(current_version < 40)
		if(ignore_question && ignore_question.len)
			if("Lavra" in ignore_question)
				ignore_question -= "Lavra"
				ignore_question |= IGNORE_LARVA
				S["ignore_question"] << ignore_question

	if(current_version < 42)
		if(ROLE_NINJA in be_role)
			be_role -= ROLE_NINJA
		if(ROLE_ABDUCTOR in be_role)
			be_role -= ROLE_ABDUCTOR
		S["be_role"] << be_role

	// if you change a values in global.special_roles_ignore_question, you can copypaste this code
	if(current_version < 45)
		if(ignore_question && ignore_question.len)
			var/list/diff = ignore_question - global.full_ignore_question
			if(diff.len)
				S["ignore_question"] << ignore_question - diff

	if(current_version < 48)
		S["b_type"] << null

	if(current_version < 49)
		if("Imposter" in be_role)
			be_role -= "Imposter"
			S["be_role"] << be_role

	if(current_version < 50)

		if(player_alt_titles && (player_alt_titles["Assistant"] in list("Reporter")))
			player_alt_titles -= "Assistant"
		if(player_alt_titles && (player_alt_titles["Librarian"] in list("Journalist")))
			player_alt_titles -= "Librarian"

	if(current_version < 52)
		var/static/list/pre_52_hairstyles_to_modern_ones = list (
			"Bald" = "Bald",
			"Short Hair" = "Arnold - Short",
			"Short Hair 2" = "Arnold - Short",
			"Cut Hair" = "Crew Cut- Super Short",
			"Shoulder-length Hair" = "Hime Cut - New Fashion",
			"Long Hair" = "Emo - Long",
			"Long Over Eye" = "Emo - Long",
			"Very Long Hair" = "Emo - Long",
			"Long Fringe" = "Longe Fringe Pirat - Movie",
			"Longer Fringe" = "Longe Fringe Pirat - Movie",
			"Gentle" = "Gentle - Short",
			"Half-banged Hair" = "Lbang - Short",
			"Half-banged Hair 2" = "Lbang - Short",
			"Ponytail" = "Ponytail",
			"Ponytail 2" = "Ponytail 2",
			"Ponytail 3" = "Ponytail 3",
			"Side Pony" = "Ponytail (f)",
			"Side Pony 2" = "Ponytail (f)",
			"Side Pony tail" = "Ponytail (f)",
			"One Shoulder" = "Side Tail - New Fashion",
			"Tress Shoulder" = "Side Tail - New Fashion",
			"Parted" = "Parted - Short",
			"Pompadour" = "Fastline Dandy - Movie",
			"Big Pompadour" = "Fastline Dandy - Movie",
			"Quiff" = "Quiff - Short",
			"Bedhead" = "Bedhead",
			"Bedhead 2" = "Bedhead 2",
			"Bedhead 3" = "Bedhead 3",
			"Messy" = "Messy - Short",
			"Beehive" = "Beehive",
			"Bobcurl" = "Bobcurl",
			"Bob" = "Bobcut",
			"Bowl" = "Bowlcut",
			"Buzzcut" = "Buzz Cut",
			"Crewcut" = "Crew Cut - Super Short",
			"Cotton Hair" = "Side Tail - New Fashion",
			"Braided Hair" = "African - Long",
			"African Pigtails" = "African - Long",
			"Square" = "Square - Short",
			"Combover" = "Cowboy - Short",
			"Devil Lock" = "Devil - Super Short",
			"Dreadlocks" = "Dreads - Short",
			"Curls" =  "Bobcurl",
			"Afro" = "Afro 1 - Short",
			"Afro 2" = "Afro 2 - Short",
			"Big Afro" = "Afro 2 - Short",
			"Flat Top" = "Flat top - Short",
			"Emo" = "Demo - Short",
			"Flow Hair" = "Feather 1 - Short",
			"Feather" = "Feather 1 - Short",
			"Hitop" = "Feather 1 - Short",
			"Mohawk" = "Mohawk Randy - Movie",
			"Jensen Hair" = "Feather 1 - Short",
			"Gelled Back" = "Gelled - Super Short",
			"Spiky" = "Spiky - Short",
			"Spiky 2" = "Spiky - Short",
			"Spiky 3" = "Spiky - Short",
			"Slightly long" = "Slight Messy Tereza 1 - Movie",
			"Kusanagi Hair" = "Gelled - Super Short",
			"Kagami Hair" = "Gelled - Super Short",
			"Pigtails" = "Side Tail - New Fashion",
			"Pigtails 2" = "Side Tail - New Fashion",
			"Hime Cut" = "Hime Cut - New Fashion",
			"Ahoge" = "Bunstick",
			"Low Braid" = "Braid - Long",
			"High Braid" = "Braid - Long",
			"Floorlength Braid" = "Bunstick",
			"Odango" = "Bunstick",
			"Ombre" = "Ombre - Short",
			"Updo" = "Updo - Short",
			"Skinhead" = "Skinhead - Super Short",
			"Balding Hair" = "Skinhead - Super Short",
			"Bun Head" = "Bun",
			"Braided Tail" = "Braided Sanny - Movie",
			"Drill Hair" = "Braided Sanny 2 - Movie",
			"Keanu Hair" = "Braided Sanny 2 - Movie",
			"Swept Back Hair 2" = "Braided Sanny - Movie",
			"Business Hair 3" = "Business",
			"Business Hair 4" = "Business 2",
			"Hedgehog Hair" = "Spiky - Short",
			"Bob Hair" = "Bobcut",
			"Bob Hair 2" = "Bobcurl",
			"Long Hair 1" = "Side Part - Long",
			"Mega Eyebrows" = "Megabrows - Super Short",
			"Flaired Hair" = "Braid - Long",
			"Big tails" = "Wisp - Ponytail",
			"Long bedhead" = "Bedhead - Long",
			"Fluttershy" = "Fluttershy - Long",
			"Judge" = "Judge - Long",
			"Long braid" = "Braid - Long",
			"Elize" = "Elize - Short",
			"Elize2" = "Elize 2 - Short",
			"Female undercut" = "Zorg - Short",
			"Emo right" = "Zorg - Short",
			"Applejack" = "Wisp - Ponytail",
			"Rosa" = "Rosa - Short",
			"Dave" =  "Dave - Short",
			"Aradia" = "Aradia - Long",
			"Nepeta" = "Nepeta - Short",
			"Kanaya" = "Kanaya - Short",
			"Terezi" = "Slight Messy Tereza 1 - Movie",
			"Vriska" = "Vriska - New Fashion",
			"Equius" = "Nepeta - Short",
			"Gamzee" = "Gamzee - Short",
			"Feferi" = "Gamzee - Short",
			"Rose" = "Rose - New Fashion",
			"Ramona" = "CIA - Short",
			"Dirk" = "Dirk - Short",
			"Jade" = "Dirk - Short",
			"Roxy" = "Roxy - Short",
			"Side tail 3" = "Side Tail - New Fashion",
			"Big Flat Top" = "Flat top - Short",
			"Dubs Hair " = "Dubs - Short",
			"Swept Back Hair" = "Dubs - Short",
			"Metal" = "Mentalist - Short",
			"Mentalist" = "Mentalist - Short",
			"fujisaki" = "Fujiyabash - New Fashion",
			"Twin Buns" = "Double Bun",
			"Fujiyabashi" = "Fujiyabash - New Fashion",
			"Shinibu" =  "Double Bun",
			"Combed Hair" = "Dad 2 - Short",
			"Long Sideparts" = "Side Part - Long",
			"Blunt Bangs" = "Bluntbangs - Long",
			"Combed Bob" = "Dad 2 - Short",
			"Long Half Shaved" = "Halfshaved - Long",
			"Slightly Messed" = "Messy - Short",
			"Long Gypsy" = "Gipsy - Long",
			"Geisha" =  "Geisha - Short",
			"Hair Over Eye" = "Over Eye - New Fashion",
			"Chub" = "Chub - Short",
			"Ponytail female" = "Ponytail (f)",
			"Wisp" = "Wisp - Ponytail",
			"Half-Shaved Emo" = "Emo - Long",
			"Long Hair Alt 2" = "Wild - Long",
			"Bun 4" = "Double Bun 2",
			"Double-Bun" = "Double Bun 3",
			"Rows" = "Rows - Gang",
			"Rows 2" = "Rows 2 - Gang",
			"Twintail" = "Nitori - New Fashion",
			"Coffee House Cut" = "Hime Cut - New Fashion",
			"Overeye Very Short" = "Over Eye - New Fashion",
			"Oxton" = "Oxton - Short",
			"Zieglertail" = "Ziegler - Ponytail",
			"Emo Fringe" = "Emo - Long",
			"Poofy2" = "Poofy - Short",
			"Fringetail" = "Ponytail (f)",
			"Bun 3" = "Bunstick",
			"Overeye Very Short, Alternate" = "Ougi - Short",
			"Undercut Swept Right" = "Blackswordcut",
			"Spiky Ponytail" = "Brazeska - Ponytail",
			"Grande Braid" = "Braid - Long",
			"Row Bun" = "Row bun - Gang",
			"Row Dual Braid" = "Row bun - Gang",
			"Row Braid" = "Row bun - Gang",
			"Regulation Mohawk" = "Mohawk Randy - Movie",
			"Topknot" = "Chao Topknot - Gang",
			"Ronin" = "Jensen - Short",
			"Bowl 2" = "Bowlcut",
			"Manbun" = "Small Beehive",
			"Country" = "Ponytail (f)",
			"Ougi" = "Ougi - Short",
			"Half Zingertail" = "Half Ziegler - Ponytail",
			"Lbangs 2" = "Lbang - Short",
			"Slight Messy 2" = "Slight Messy Tereza 2 - Movie",
			"Ragby" = "Rabby - Ponytail",
			"Bun 5" = "Double Bun 3",
			"Maya" = "Maya - Short",
			"Dolly" = "Dolly - Short",
			"Longside Partstraight 2" = "Side Part 2 - Long",
			"Elly" = "Elly - Short",
			"Wild 1" = "Wild - Long",
			"Wild 2" = "Wild Princess - Movie",
			"Millenium" = "Millenium - Short",
			"Feather 2" = "Feathe 2 - Short",
			"Braided Hair 2" = "Braided Sanny 2 - Movie",
			"Fridge" = "Fridge - Short",
			"Rabby" = "Rabby - Ponytail",
			"Zoey" = "Zoe - Ponytail",
			"Kitty" = "Kitty - Short",
			"Star" = "Star - Movie",
			"Pear" = "Pear - Short",
			"Spicy" = "Spicy - Short",
			"Piggy" = "Piggy - Short",
		)
		if (pre_52_hairstyles_to_modern_ones[h_style])
			h_style = pre_52_hairstyles_to_modern_ones[h_style]

	if(current_version < 53)
		ipc_head = initial(ipc_head)
		// fuck named hairstyles, we should just move it to indexes
		var/static/list/ipc_hairstyles_reset = list(
			"alien IPC screen", 
			"double IPC screen", 
			"pillar IPC screen", 
			"human IPC screen"
		)
		if(h_style in ipc_hairstyles_reset)
			h_style = /datum/sprite_accessory/hair/ipc_screen_alert::name

	if(current_version < 54)
		// cap dark colors for old preferences, should be part of pref sanitize but better to wait for datumized preferences
		var/new_hex = color_luminance_min(rgb(r_skin, g_skin, b_skin), 10)
		r_skin = HEX_VAL_RED(new_hex)
		g_skin = HEX_VAL_GREEN(new_hex)
		b_skin = HEX_VAL_BLUE(new_hex)

		new_hex = color_luminance_min(rgb(r_belly, g_belly, b_belly), 10)
		r_belly = HEX_VAL_RED(new_hex)
		g_belly = HEX_VAL_GREEN(new_hex)
		b_belly = HEX_VAL_BLUE(new_hex)

		// converts old skin tone to approximate datum
		switch(clamp(35 - s_tone, 1, 220))
			if(1 to 14)
				s_tone = /datum/skin_tone/albino::name
			if(15 to 28)
				s_tone = /datum/skin_tone/porcelain::name
			if(29 to 41)
				s_tone = /datum/skin_tone/ivory::name
			if(42 to 55)
				s_tone = /datum/skin_tone/light_peach::name
			if(56 to 69)
				s_tone = /datum/skin_tone/beige::name
			if(70 to 83)
				s_tone = /datum/skin_tone/light_brown::name
			if(84 to 97)
				s_tone = /datum/skin_tone/peach::name
			if(98 to 110)
				s_tone = /datum/skin_tone/light_beige::name
			if(111 to 124)
				s_tone = /datum/skin_tone/olive::name
			if(125 to 138)
				s_tone = /datum/skin_tone/chestnut::name
			if(139 to 152)
				s_tone = /datum/skin_tone/macadamia::name
			if(153 to 165)
				s_tone = /datum/skin_tone/walnut::name
			if(166 to 179)
				s_tone = /datum/skin_tone/coffee::name
			if(180 to 193)
				s_tone = /datum/skin_tone/brown::name
			if(194 to 207)
				s_tone = /datum/skin_tone/medium_brown::name
			if(208 to 220)
				s_tone = /datum/skin_tone/dark_brown::name
			else
				s_tone = initial(s_tone)

	// if you change a values in global.special_roles_ignore_question, you can copypaste this code
	if(current_version < 55)
		if(ignore_question && ignore_question.len)
			var/list/diff = ignore_question - global.full_ignore_question
			if(diff.len)
				S["ignore_question"] << ignore_question - diff

	if(current_version < 56)
		underwear = /datum/preferences::underwear
		undershirt = /datum/preferences::undershirt
		undershirt_print = /datum/preferences::undershirt_print
		socks = /datum/preferences::socks

//
/datum/preferences/proc/repetitive_updates_character(current_version, savefile/S)

	if(current_version < SAVEFILE_VERSION_SPECIES_JOBS)
		if(species != HUMAN)
			for(var/datum/job/job as anything in SSjob.all_occupations)
				if(!job.is_species_permitted(species))
					SetJobPreferenceLevel(job, 0)
			S["job_preferences"] << job_preferences

	if(current_version < SAVEFILE_VERSION_QUIRKS)
		for(var/quirk_name in all_quirks)
			// If the quirk isn't even hypothetically allowed, pref can't have it.
			// If IsAllowedQuirk() for some reason ever becomes more computationally
			// difficult than (quirk_name in allowed_quirks), please change to the latter. ~Luduk
			if(!IsAllowedQuirk(quirk_name))
				popup(parent, "Your character([real_name]) had incompatible quirks on them. This character's quirks have been reset.", "Preferences")
				ResetQuirks()
				break

/// checks through keybindings for outdated unbound keys and updates them
/datum/preferences/proc/check_keybindings()
	if(!parent)
		return

	// When loading from savefile key_binding can be null
	// This happens when player had savefile created before new kb system, but hotkeys was not saved
	if(!length(key_bindings))
		key_bindings = deepCopyList(global.hotkey_keybinding_list_by_key) // give them default keybinds too

	var/list/user_binds = list()
	for (var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)
	var/list/notadded = list()
	for (var/name in global.keybindings_by_name)
		var/datum/keybinding/kb = global.keybindings_by_name[name]
		if(length(user_binds[kb.name]))
			continue // key is unbound and or bound to something
		var/addedbind = FALSE
		for(var/hotkeytobind in kb.hotkey_keys)
			if(!length(key_bindings[hotkeytobind]))
				LAZYADD(key_bindings[hotkeytobind], kb.name)
				addedbind = TRUE
		if(!addedbind)
			notadded += kb
	if(length(notadded))
		addtimer(CALLBACK(src, PROC_REF(announce_conflict), notadded), 5 SECONDS)

/datum/preferences/proc/announce_conflict(list/notadded)
	to_chat(parent, "<span class='userdanger'>KEYBINDING CONFLICT!!!\n\
	There are new keybindings that have defaults bound to keys you already set, They will default to Unbound. You can bind them in Setup Character or Game Preferences\n\
	<a href='byond://?_src_=prefs;preference=tab;tab=3'>Or you can click here to go straight to the keybindings page</a></span>")
	for(var/item in notadded)
		var/datum/keybinding/conflicted = item
		to_chat(parent, "<span class='userdanger'>[conflicted.category]: [conflicted.full_name] needs updating</span>")
		LAZYADD(key_bindings["None"], conflicted.name) // set it to unbound to prevent this from opening up again in the future

/datum/preferences/proc/load_path(ckey, filename = "preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)
		return 0
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == SAVEFILE_TOO_OLD) // fatal, can't load any data
		return 0

	//General preferences
	S["ooccolor"]          >> ooccolor
	S["aooccolor"]         >> aooccolor
	S["lastchangelog"]     >> lastchangelog
	S["UI_style"]          >> UI_style
	S["UI_style_color"]    >> UI_style_color
	S["UI_style_alpha"]    >> UI_style_alpha
	S["clientfps"]         >> clientfps
	S["default_slot"]      >> default_slot
	S["chat_toggles"]      >> chat_toggles
	S["toggles"]           >> toggles
	S["chat_ghostsight"]   >> chat_ghostsight
	S["randomslot"]        >> randomslot
	S["parallax"]          >> parallax
	S["ambientocclusion"]  >> ambientocclusion
	S["glowlevel"]         >> glowlevel
	S["lampsexposure"]     >> lampsexposure
	S["lampsglare"]        >> lampsglare
	S["eye_blur_effect"]   >> eye_blur_effect
	S["auto_fit_viewport"] >> auto_fit_viewport
	S["lobbyanimation"]    >> lobbyanimation
	S["tooltip"]           >> tooltip
	S["tooltip_size"]      >> tooltip_size
	S["tooltip_font"]      >> tooltip_font
	S["outline_enabled"]   >> outline_enabled
	S["outline_color"]     >> outline_color
	S["eorg_enabled"]      >> eorg_enabled
	S["show_runechat"]     >> show_runechat
	S["emote_panel"]       >> custom_emote_panel

	// Custom hotkeys
	S["key_bindings"] >> key_bindings
	check_keybindings()
	S["hotkeys"]      >> hotkeys

	//TGUI
	S["tgui_fancy"]		>> tgui_fancy
	S["tgui_lock"]		>> tgui_lock
	S["window_scale"]	>> window_scale

	//Sound preferences
	S["snd_music_vol"]                      >> snd_music_vol
	S["snd_ambient_vol"]                    >> snd_ambient_vol
	S["snd_effects_master_vol"]             >> snd_effects_master_vol
	S["snd_effects_voice_announcement_vol"]	>> snd_effects_voice_announcement_vol
	S["snd_effects_misc_vol"]               >> snd_effects_misc_vol
	S["snd_effects_instrument_vol"]         >> snd_effects_instrument_vol
	S["snd_notifications_vol"]              >> snd_notifications_vol
	S["snd_admin_vol"]                      >> snd_admin_vol
	S["snd_jukebox_vol"]                    >> snd_jukebox_vol

	//*** FOR FUTURE UPDATES, SO YOU KNOW WHAT TO DO ***//
	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S) // needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	ooccolor		= normalize_color(sanitize_hexcolor(ooccolor, initial(ooccolor)))
	aooccolor		= normalize_color(sanitize_hexcolor(aooccolor, initial(aooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, global.available_ui_styles, global.available_ui_styles[1])
	clientfps		= sanitize_integer(clientfps, -1, 1000, -1)
	default_slot	= sanitize_integer(default_slot, 1, GET_MAX_SAVE_SLOTS(parent), initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	chat_toggles	= sanitize_integer(chat_toggles, 0, 65535, initial(chat_toggles))
	chat_ghostsight	= sanitize_integer(chat_ghostsight, CHAT_GHOSTSIGHT_ALL, CHAT_GHOSTSIGHT_NEARBYMOBS, CHAT_GHOSTSIGHT_ALL)
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	key_bindings 	= sanitize_keybindings(key_bindings)
	hotkeys 		= sanitize_integer(hotkeys, 0, 1, initial(hotkeys))
	tgui_fancy		= sanitize_integer(tgui_fancy, 0, 1, initial(tgui_fancy))
	tgui_lock		= sanitize_integer(tgui_lock, 0, 1, initial(tgui_lock))
	window_scale		= sanitize_integer(window_scale, 0, 1, initial(window_scale))
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, PARALLAX_HIGH)
	ambientocclusion	= sanitize_integer(ambientocclusion, 0, 1, initial(ambientocclusion))
	glowlevel		= sanitize_integer(glowlevel, GLOW_HIGH, GLOW_DISABLE, initial(glowlevel))
	eye_blur_effect = sanitize_integer(eye_blur_effect, 0, 1, initial(eye_blur_effect))
	lampsexposure	= sanitize_integer(lampsexposure, 0, 1, initial(lampsexposure))
	lampsglare		= sanitize_integer(lampsglare, 0, 1, initial(lampsglare))
	lobbyanimation	= sanitize_integer(lobbyanimation, 0, 1, initial(lobbyanimation))
	auto_fit_viewport	= sanitize_integer(auto_fit_viewport, 0, 1, initial(auto_fit_viewport))
	tooltip = sanitize_integer(tooltip, 0, 1, initial(tooltip))
	tooltip_size 	= sanitize_integer(tooltip_size, 1, 15, initial(tooltip_size))
	outline_enabled = sanitize_integer(outline_enabled, 0, 1, initial(outline_enabled))
	outline_color 	= normalize_color(sanitize_hexcolor(outline_color, initial(outline_color)))
	eorg_enabled 	= sanitize_integer(eorg_enabled, 0, 1, initial(eorg_enabled))
	show_runechat	= sanitize_integer(show_runechat, 0, 1, initial(show_runechat))
	custom_emote_panel  = sanitize_emote_panel(custom_emote_panel)

	snd_music_vol	= sanitize_integer(snd_music_vol, 0, 100, initial(snd_music_vol))
	snd_ambient_vol = sanitize_integer(snd_ambient_vol, 0, 100, initial(snd_ambient_vol))
	snd_effects_master_vol	= sanitize_integer(snd_effects_master_vol, 0, 100, initial(snd_effects_master_vol))
	snd_effects_voice_announcement_vol	= sanitize_integer(snd_effects_voice_announcement_vol, 0, 100, initial(snd_effects_voice_announcement_vol))
	snd_effects_misc_vol	= sanitize_integer(snd_effects_misc_vol, 0, 100, initial(snd_effects_misc_vol))
	snd_effects_instrument_vol	= sanitize_integer(snd_effects_instrument_vol, 0, 100, initial(snd_effects_instrument_vol))
	snd_notifications_vol	= sanitize_integer(snd_notifications_vol, 0, 100, initial(snd_notifications_vol))
	snd_admin_vol	= sanitize_integer(snd_admin_vol, 0, 100, initial(snd_admin_vol))
	snd_jukebox_vol = sanitize_integer(snd_jukebox_vol, 0, 100, initial(snd_jukebox_vol))

	if(needs_update >= 0) //save the updated version
		var/old_default_slot = default_slot
		for (var/slot in S.dir) //but first, update all current character slots.
			if (copytext(slot, 1, 10) != "character")
				continue
			var/slotnum = text2num(copytext(slot, 10))
			if (!slotnum)
				continue
			default_slot = slotnum
			if (load_character())
				save_character()
		default_slot = old_default_slot
		save_preferences()

	return 1

/datum/preferences/proc/save_preferences()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	S["version"] << SAVEFILE_VERSION_MAX

	//general preferences
	S["ooccolor"]          << ooccolor
	S["aooccolor"]         << aooccolor
	S["lastchangelog"]     << lastchangelog
	S["UI_style"]          << UI_style
	S["UI_style_color"]    << UI_style_color
	S["UI_style_alpha"]    << UI_style_alpha
	S["clientfps"]         << clientfps
	S["default_slot"]      << default_slot
	S["toggles"]           << toggles
	S["chat_toggles"]      << chat_toggles
	S["chat_ghostsight"]   << chat_ghostsight
	S["randomslot"]        << randomslot
	S["parallax"]          << parallax
	S["ambientocclusion"]  << ambientocclusion
	S["glowlevel"]         << glowlevel
	S["eye_blur_effect"]   << eye_blur_effect
	S["lampsexposure"]     << lampsexposure
	S["lampsglare"]        << lampsglare
	S["lobbyanimation"]    << lobbyanimation
	S["auto_fit_viewport"] << auto_fit_viewport
	S["tooltip"]           << tooltip
	S["tooltip_size"]      << tooltip_size
	S["tooltip_font"]      << tooltip_font
	S["emote_panel"]       << custom_emote_panel


	// Custom hotkeys
	S["key_bindings"] << key_bindings
	S["hotkeys"]      << hotkeys

	S["outline_enabled"] << outline_enabled
	S["outline_color"]   << outline_color
	S["eorg_enabled"]    << eorg_enabled
	S["show_runechat"]   << show_runechat
	//TGUI
	S["tgui_fancy"]		<< tgui_fancy
	S["tgui_lock"]		<< tgui_lock
	S["window_scale"]		<< window_scale

	//Sound preferences
	S["snd_music_vol"]                      << snd_music_vol
	S["snd_ambient_vol"]                    << snd_ambient_vol
	S["snd_effects_master_vol"]             << snd_effects_master_vol
	S["snd_effects_voice_announcement_vol"] << snd_effects_voice_announcement_vol
	S["snd_effects_misc_vol"]               << snd_effects_misc_vol
	S["snd_effects_instrument_vol"]         << snd_effects_instrument_vol
	S["snd_notifications_vol"]              << snd_notifications_vol
	S["snd_admin_vol"]                      << snd_admin_vol
	S["snd_jukebox_vol"]                    << snd_jukebox_vol
	return 1

/datum/preferences/proc/load_saved_character(dir)
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = dir

	var/needs_update = savefile_needs_update(S)
	if(needs_update == SAVEFILE_TOO_OLD) // fatal, can't load any data
		return 0

	//Character
	S["OOC_Notes"]             >> metadata
	S["real_name"]             >> real_name
	S["name_is_always_random"] >> be_random_name
	S["gender"]                >> gender
	S["neuter_gender_voice"]   >> neuter_gender_voice
	S["age"]                   >> age
	S["height"]                >> height
	S["species"]               >> species
	S["language"]              >> language

	//colors to be consolidated into hex strings (requires some work with dna code)
	S["hair_red"]          >> r_hair
	S["hair_green"]        >> g_hair
	S["hair_blue"]         >> b_hair
	S["belly_red"]         >> r_belly
	S["belly_green"]       >> g_belly
	S["belly_blue"]        >> b_belly
	S["grad_red"]          >> r_grad
	S["grad_green"]        >> g_grad
	S["grad_blue"]         >> b_grad
	S["facial_red"]        >> r_facial
	S["facial_green"]      >> g_facial
	S["facial_blue"]       >> b_facial
	S["skin_tone"]         >> s_tone
	S["skin_red"]          >> r_skin
	S["skin_green"]        >> g_skin
	S["skin_blue"]         >> b_skin
	S["hair_style_name"]   >> h_style
	S["grad_style_name"]   >> grad_style
	S["facial_style_name"] >> f_style
	S["eyes_red"]          >> r_eyes
	S["eyes_green"]        >> g_eyes
	S["eyes_blue"]         >> b_eyes
	S["underwear"]         >> underwear
	S["undershirt"]        >> undershirt
	S["undershirt_print"]  >> undershirt_print
	S["socks"]             >> socks
	S["backbag"]           >> backbag
	S["use_skirt"]         >> use_skirt
	S["pda_ringtone"]      >> chosen_ringtone
	S["pda_custom_melody"] >> custom_melody

	//Load prefs
	S["alternate_option"] >> alternate_option
	S["job_preferences"]  >> job_preferences

	//Traits
	S["all_quirks"]       >> all_quirks
	S["positive_quirks"]  >> positive_quirks
	S["negative_quirks"]  >> negative_quirks
	S["neutral_quirks"]   >> neutral_quirks

	//Miscellaneous
	S["flavor_text"]       >> flavor_text
	S["med_record"]        >> med_record
	S["sec_record"]        >> sec_record
	S["gen_record"]        >> gen_record
	S["be_role"]           >> be_role
	S["ignore_question"]   >> ignore_question
	S["player_alt_titles"] >> player_alt_titles
	S["organ_data"]        >> organ_data
	S["ipc_head"]          >> ipc_head
	S["gear"]              >> gear
	S["custom_items"]      >> custom_items

	S["nanotrasen_relation"] >> nanotrasen_relation
	S["home_system"]         >> home_system
	S["citizenship"]         >> citizenship
	S["insurance"]           >> insurance
	S["faction"]             >> faction
	S["religion"]            >> religion
	S["vox_rank"]            >> vox_rank

	S["uplinklocation"]      >> uplinklocation

	UpdateAllowedQuirks()

	//*** FOR FUTURE UPDATES, SO YOU KNOW WHAT TO DO ***//
	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S) // needs_update == savefile_version if we need an update (positive integer)
		repetitive_updates_character(needs_update, S)

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= sanitize_name(real_name)

	if(isnull(species))
		species = HUMAN
	var/datum/species/species_obj = all_species[species]

	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(!real_name) real_name = random_name(gender)
	if(!gear) gear = list()
	if(!custom_items) custom_items = list()
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender, species_obj.flags[NO_GENDERS])
	age				= sanitize_integer(age, species_obj.min_age, species_obj.max_age, initial(age))
	height			= sanitize_inlist(height, heights_list, initial(height))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_grad			= sanitize_integer(r_grad, 0, 255, initial(r_grad))
	g_grad			= sanitize_integer(g_grad, 0, 255, initial(g_grad))
	b_grad			= sanitize_integer(b_grad, 0, 255, initial(b_grad))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_inlist(s_tone, global.skin_tones_by_name, initial(s_tone))
	r_skin			= sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin			= sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin			= sanitize_integer(b_skin, 0, 255, initial(b_skin))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	grad_style		= sanitize_inlist(grad_style, hair_gradients, initial(grad_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_integer(underwear, 0, underwear_t.len, initial(underwear))
	undershirt		= sanitize_integer(undershirt, 0, undershirt_t.len, initial(undershirt))
	undershirt_print = sanitize_inlist(undershirt_print, undershirt_prints_t, null)
	socks			= sanitize_integer(socks, 0, socks_t.len, initial(socks))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	var/list/pref_ringtones = global.ringtones_by_names + CUSTOM_RINGTONE_NAME
	chosen_ringtone  = sanitize_inlist(chosen_ringtone, pref_ringtones, initial(chosen_ringtone))
	custom_melody = sanitize(custom_melody, MAX_CUSTOM_RINGTONE_LENGTH, extra = FALSE, ascii_only = TRUE)
	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	neuter_gender_voice = sanitize_gender_voice(neuter_gender_voice)

	all_quirks = SANITIZE_LIST(all_quirks)
	positive_quirks = SANITIZE_LIST(positive_quirks)
	negative_quirks = SANITIZE_LIST(negative_quirks)
	neutral_quirks = SANITIZE_LIST(neutral_quirks)

	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()
	if(!ipc_head) src.ipc_head = "Default"
	if(!be_role) src.be_role = list()
	if(!ignore_question) src.ignore_question = list()

	if(!home_system) home_system = "None"
	if(!citizenship) citizenship = "None"
	if(!insurance)   insurance = INSURANCE_STANDARD
	if(!faction)     faction =     "None"
	if(!religion)    religion =    "None"
	if(!vox_rank)    vox_rank =    "Larva"

/datum/preferences/proc/random_character()
	if(!path)
		return 0
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	var/list/saves = list()
	var/name
	for(var/i = 1 to GET_MAX_SAVE_SLOTS(parent))
		S.cd = "/character[i]"
		S["real_name"] >> name
		if(!name)
			continue
		saves.Add(S.cd)

	if(!saves.len)
		load_character()
		return 0
	S.cd = pick(saves)
	load_saved_character(S.cd)
	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)
		return 0
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, GET_MAX_SAVE_SLOTS(parent), initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot
	S.cd = "/character[slot]"
	load_saved_character(S.cd)

	return 1

/datum/preferences/proc/save_character()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/character[default_slot]"

	S["version"] << SAVEFILE_VERSION_MAX // load_character will sanitize any bad data, so assume up-to-date.

	//Character
	S["OOC_Notes"]             << metadata
	S["real_name"]             << real_name
	S["name_is_always_random"] << be_random_name
	S["gender"]                << gender
	S["neuter_gender_voice"]   << neuter_gender_voice
	S["age"]                   << age
	S["height"]                << height
	S["species"]               << species
	S["language"]              << language
	S["hair_red"]              << r_hair
	S["hair_green"]            << g_hair
	S["hair_blue"]             << b_hair
	S["belly_red"]             << r_belly
	S["belly_green"]           << g_belly
	S["belly_blue"]            << b_belly
	S["grad_red"]              << r_grad
	S["grad_green"]            << g_grad
	S["grad_blue"]             << b_grad
	S["facial_red"]            << r_facial
	S["facial_green"]          << g_facial
	S["facial_blue"]           << b_facial
	S["skin_tone"]             << s_tone
	S["skin_red"]              << r_skin
	S["skin_green"]            << g_skin
	S["skin_blue"]             << b_skin
	S["hair_style_name"]       << h_style
	S["grad_style_name"]       << grad_style
	S["facial_style_name"]     << f_style
	S["eyes_red"]              << r_eyes
	S["eyes_green"]            << g_eyes
	S["eyes_blue"]             << b_eyes
	S["underwear"]             << underwear
	S["undershirt"]            << undershirt
	S["socks"]                 << socks
	S["backbag"]               << backbag
	S["use_skirt"]             << use_skirt
	S["pda_ringtone"]          << chosen_ringtone
	S["pda_custom_melody"]     << custom_melody
	//Write prefs
	S["alternate_option"]      << alternate_option
	S["job_preferences"]       << job_preferences

	//Traits
	S["all_quirks"]      << all_quirks
	S["positive_quirks"] << positive_quirks
	S["negative_quirks"] << negative_quirks
	S["neutral_quirks"]  << neutral_quirks

	//Miscellaneous
	S["flavor_text"]       << flavor_text
	S["med_record"]        << med_record
	S["sec_record"]        << sec_record
	S["gen_record"]        << gen_record
	S["be_role"]           << be_role
	S["ignore_question"]   << ignore_question
	S["player_alt_titles"] << player_alt_titles
	S["organ_data"]        << organ_data
	S["ipc_head"]          << ipc_head
	S["gear"]              << gear
	S["custom_items"]      << custom_items

	S["nanotrasen_relation"] << nanotrasen_relation
	S["home_system"]         << home_system
	S["citizenship"]         << citizenship
	S["insurance"]           << insurance
	S["faction"]             << faction
	S["religion"]            << religion
	S["vox_rank"]            << vox_rank
	S["uplinklocation"]      << uplinklocation

	return 1

/proc/sanitize_keybindings(value)
	var/list/base_bindings = sanitize_islist(value,list())
	for(var/key in base_bindings)
		base_bindings[key] = base_bindings[key] & global.keybindings_by_name
		if(!length(base_bindings[key]))
			base_bindings -= key
	return base_bindings

/proc/sanitize_emote_panel(value)
	var/list/emote_panel = SANITIZE_LIST(value)
	var/list/sanitized_emote_panel = list()
	for(var/key in emote_panel)
		if(!(key in global.emotes_for_emote_panel))
			continue
		sanitized_emote_panel |= key
	return sanitized_emote_panel

#undef SAVEFILE_TOO_OLD
#undef SAVEFILE_UP_TO_DATE
#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
