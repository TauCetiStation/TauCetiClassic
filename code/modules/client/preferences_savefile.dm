var/global/list/legacy_keyname_to_pref = list()

//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 8

//This is the current version, anything below this will attempt to update (if it's not obsolete)

#define SAVEFILE_VERSION_MAX 51

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


/datum/preferences/proc/convert_preferences(savefile/S)
	// audio
	set_pref(/datum/pref/player/audio/lobby, S["snd_music_vol"])
	set_pref(/datum/pref/player/audio/ambient, S["snd_ambient_vol"])
	set_pref(/datum/pref/player/audio/notifications, S["snd_notifications_vol"])
	set_pref(/datum/pref/player/audio/admin_sounds, S["snd_admin_vol"])
	set_pref(/datum/pref/player/audio/jukebox, S["snd_jukebox_vol"])

	set_pref(/datum/pref/player/audio/effects, S["snd_effects_master_vol"])
	var/effects_coeff = S["snd_effects_master_vol"] * 0.01
	set_pref(/datum/pref/player/audio/voice_announcements, S["snd_effects_voice_announcement_vol"] * effects_coeff)
	set_pref(/datum/pref/player/audio/instruments, S["snd_effects_instrument_vol"] * effects_coeff)
	set_pref(/datum/pref/player/audio/spam_effects, S["snd_effects_misc_vol"]) // no coefficient as this still depends on the effects audio slider

	// ui
	set_pref(/datum/pref/player/display/auto_fit_viewport, S["auto_fit_viewport"])
	set_pref(/datum/pref/player/ui/ui_style, S["UI_style"])
	set_pref(/datum/pref/player/ui/ui_style_color, S["UI_style_color"])
	var/converted_alpha = 100 - floor(100*S["UI_style_alpha"]/255)
	set_pref(/datum/pref/player/ui/ui_style_opacity, converted_alpha)
	set_pref(/datum/pref/player/ui/outline, S["outline_enabled"])
	set_pref(/datum/pref/player/ui/outline_color, S["outline_color"])
	set_pref(/datum/pref/player/ui/runechat, S["show_runechat"])
	set_pref(/datum/pref/player/ui/tooltip, S["tooltip"])
	set_pref(/datum/pref/player/ui/tooltip_font, S["tooltip_font"])
	set_pref(/datum/pref/player/ui/tooltip_size, S["tooltip_size"])

	//set_pref(/datum/pref/player/ui/..., S["tgui_fancy"]) // removed, we don't support ie8 already and 516 is coming
	set_pref(/datum/pref/player/ui/tgui_lock, S["tgui_lock"])

	// graphics
	var/converted_fps = S["clientfps"] == -1 ? RECOMMENDED_FPS : S["clientfps"] // before -1 was for default, but it's confusing and we don't change it too often
	set_pref(/datum/pref/player/display/fps, converted_fps)

	var/converted_parallax
	switch(S["parallax"])
		if(-1)
			converted_parallax = PARALLAX_INSANE
		if(0)
			converted_parallax = PARALLAX_HIGH
		if(1)
			converted_parallax = PARALLAX_MED
		if(2)
			converted_parallax = PARALLAX_LOW
		if(3)
			converted_parallax = PARALLAX_DISABLE
	set_pref(/datum/pref/player/effects/parallax, converted_parallax)
	set_pref(/datum/pref/player/effects/lobbyanimation, S["lobbyanimation"])

	var/converted_blur_effect = !S["eye_blur_effect"]
	set_pref(/datum/pref/player/effects/legacy_blur, converted_blur_effect)

	set_pref(/datum/pref/player/effects/ambientocclusion, S["ambientocclusion"])

	var/converted_glowlevel
	switch(S["glowlevel"])
		if(0)
			converted_glowlevel = GLOW_HIGH
		if(1)
			converted_glowlevel = GLOW_MED
		if(2)
			converted_glowlevel = GLOW_LOW
		if(3)
			converted_glowlevel = GLOW_DISABLE
	set_pref(/datum/pref/player/effects/glowlevel, converted_glowlevel)
	set_pref(/datum/pref/player/effects/lampsexposure, S["lampsexposure"])
	set_pref(/datum/pref/player/effects/lampsglare, S["lampsglare"])

	// game
	#define SHOW_ANIMATIONS	16
	#define SHOW_PROGBAR	32
	set_pref(/datum/pref/player/game/melee_animation, S["toggles"] & SHOW_ANIMATIONS)
	set_pref(/datum/pref/player/game/progressbar, S["toggles"] & SHOW_PROGBAR)
	#undef SHOW_ANIMATIONS
	#undef SHOW_PROGBAR

	set_pref(/datum/pref/player/game/endroundarena, S["eorg_enabled"])

	// chat
	set_pref(/datum/pref/player/chat/ooccolor, S["ooccolor"])
	set_pref(/datum/pref/player/chat/aooccolor, S["aooccolor"])

	var/const/CHAT_OOC = 1
	var/const/CHAT_DEAD = 2
	var/const/CHAT_GHOSTEARS = 4 // merged into /ghostears
	//var/const/CHAT_NOCLIENT_ATTACK = 8 // merged into new /attack_log
	var/const/CHAT_PRAYER = 16
	var/const/CHAT_RADIO = 32
	//var/const/CHAT_ATTACKLOGS = 64 // merged into new /attack_log
	var/const/CHAT_DEBUGLOGS = 128
	var/const/CHAT_LOOC = 256
	var/const/CHAT_GHOSTRADIO = 512
	//var/const/CHAT_GHOSTNPC = 1024 // merged into new /ghostantispam
	var/const/CHAT_CKEY = 2048

	set_pref(/datum/pref/player/chat/ooc, S["chat_toggles"] & CHAT_OOC)
	set_pref(/datum/pref/player/chat/dead, S["chat_toggles"] & CHAT_DEAD)
	set_pref(/datum/pref/player/chat/ghostears, S["chat_toggles"] & CHAT_GHOSTEARS)
	set_pref(/datum/pref/player/chat/prayers, S["chat_toggles"] & CHAT_PRAYER)
	set_pref(/datum/pref/player/chat/radio, S["chat_toggles"] & CHAT_RADIO)
	set_pref(/datum/pref/player/chat/debug_log, S["chat_toggles"] & CHAT_DEBUGLOGS)
	set_pref(/datum/pref/player/chat/looc, S["chat_toggles"] & CHAT_LOOC)
	set_pref(/datum/pref/player/chat/ghostradio, S["chat_toggles"] & CHAT_GHOSTRADIO)
	set_pref(/datum/pref/player/chat/show_ckey, S["chat_toggles"] & CHAT_CKEY)

	var/const/CHAT_GHOSTSIGHT_ALL = 1
	//var/const/CHAT_GHOSTSIGHT_ALLMANUAL = 2 // merged into new /ghostantispam
	var/const/CHAT_GHOSTSIGHT_NEARBYMOBS = 3

	var/converted_chat_ghostsight
	switch(S["chat_ghostsight"])
		if(CHAT_GHOSTSIGHT_ALL)
			converted_chat_ghostsight = TRUE
		if(CHAT_GHOSTSIGHT_NEARBYMOBS)
			converted_chat_ghostsight = FALSE
	set_pref(/datum/pref/player/chat/ghostsight, converted_chat_ghostsight)

	// meta domain
	set_pref(/datum/pref/player/meta/lastchangelog, S["lastchangelog"])
	set_pref(/datum/pref/player/meta/default_slot, S["default_slot"])
	set_pref(/datum/pref/player/meta/random_slot, S["randomslot"])
	set_pref(/datum/pref/player/game/hotkey_mode, S["hotkeys"])

	// emote panel
	var/list/old_emotes_list = S["emote_panel"]
	if(length(old_emotes_list))
		var/list/disabled_emotes = global.emotes_for_emote_panel - old_emotes_list
		set_pref(/datum/pref/player/meta/disabled_emotes_emote_panel, disabled_emotes)

	// keibinds
	var/list/old_keybinds = S["key_bindings"]
	var/list/keyname_to_bind = list()
	for(var/key in old_keybinds)
		for(var/keyname in old_keybinds[key])
			keyname_to_bind[keyname] = "[keyname_to_bind[keyname] ? "[keyname_to_bind[keyname]] " : "" ][key]"

	for(var/keyname in keyname_to_bind)
		var/pref_type = legacy_keyname_to_pref[keyname]
		if(keyname == "None")
			set_keybind_pref(pref_type, "")
		else
			set_keybind_pref(pref_type, keyname_to_bind[keyname])

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

	if(current_version < 26)
		for(var/role in be_role)
			if(!CanBeRole(role))
				be_role -= role

	if(current_version < 27)
		job_preferences = list() //It loaded null from nonexistant savefile field.
		var/job_civilian_high = 0
		var/job_civilian_med = 0
		var/job_civilian_low = 0

		var/job_medsci_high = 0
		var/job_medsci_med = 0
		var/job_medsci_low = 0

		var/job_engsec_high = 0
		var/job_engsec_med = 0
		var/job_engsec_low = 0

		S["job_civilian_high"] >> job_civilian_high
		S["job_civilian_med"]  >> job_civilian_med
		S["job_civilian_low"]  >> job_civilian_low
		S["job_medsci_high"]   >> job_medsci_high
		S["job_medsci_med"]    >> job_medsci_med
		S["job_medsci_low"]    >> job_medsci_low
		S["job_engsec_high"]   >> job_engsec_high
		S["job_engsec_med"]    >> job_engsec_med
		S["job_engsec_low"]    >> job_engsec_low

		//Can't use SSjob here since this happens right away on login
		for(var/job in subtypesof(/datum/job))
			var/datum/job/J = job
			var/new_value
			var/fval = initial(J.flag)
			switch(initial(J.department_flag))
				if(CIVILIAN)
					if(job_civilian_high & fval)
						// Since we can have only one high pref now, let the user pick which of the bunch they want.
						new_value = JP_MEDIUM
					else if(job_civilian_med & fval)
						new_value = JP_MEDIUM
					else if(job_civilian_low & fval)
						new_value = JP_LOW
				if(MEDSCI)
					if(job_medsci_high & fval)
						// Since we can have only one high pref now, let the user pick which of the bunch they want.
						new_value = JP_MEDIUM
					else if(job_medsci_med & fval)
						new_value = JP_MEDIUM
					else if(job_medsci_low & fval)
						new_value = JP_LOW
				if(ENGSEC)
					if(job_engsec_high & fval)
						// Since we can have only one high pref now, let the user pick which of the bunch they want.
						new_value = JP_MEDIUM
					else if(job_engsec_med & fval)
						new_value = JP_MEDIUM
					else if(job_engsec_low & fval)
						new_value = JP_LOW
			if(new_value)
				job_preferences[initial(J.title)] = new_value
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
		home_system = fix_cyrillic(home_system)
		citizenship = fix_cyrillic(citizenship)
		faction     = fix_cyrillic(faction)
		religion    = fix_cyrillic(religion)

		S["flavor_text"] << flavor_text
		S["med_record"]  << med_record
		S["sec_record"]  << sec_record
		S["gen_record"]  << gen_record
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


//
/datum/preferences/proc/repetitive_updates_character(current_version, savefile/S)

	if(current_version < SAVEFILE_VERSION_SPECIES_JOBS)
		if(species != HUMAN)
			for(var/datum/job/job in SSjob.occupations)
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

/datum/preferences/proc/load_path(ckey, filename = "preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

// loads and updates all old preferences if needed
/datum/preferences/proc/load_preferences()
	if(!path)
		return 0
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	// convert old preferences to datumized system, if we haven't done so already
	//if
	convert_preferences(S)

	// todo new update and examples

	var/needs_update = savefile_needs_update(S)
	if(needs_update == SAVEFILE_TOO_OLD) // fatal, can't load any data
		return 0

	if(needs_update >= 0) //save the updated version
		for (var/slot in S.dir) //but first, update all current character slots.
			if (copytext(slot, 1, 10) != "character")
				continue
			var/slotnum = text2num(copytext(slot, 10))
			if (!slotnum)
				continue
			if (load_character(slotnum)) // loads and updates character
				save_character(slotnum)
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
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	r_skin			= sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin			= sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin			= sanitize_integer(b_skin, 0, 255, initial(b_skin))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	grad_style		= sanitize_inlist(grad_style, hair_gradients, initial(grad_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	undershirt		= sanitize_integer(undershirt, 1, undershirt_t.len, initial(undershirt))
	socks			= sanitize_integer(socks, 1, socks_t.len, initial(socks))
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
		slot = get_pref(/datum/pref/player/meta/default_slot)
	if(!slot)
		CRASH("Attempt to access saves with empty slot")
	S.cd = "/character[slot]"
	load_saved_character(S.cd)

	return 1

/datum/preferences/proc/save_character(slot)
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	if(!slot)
		slot = get_pref(/datum/pref/player/meta/default_slot)
	if(!slot)
		CRASH("Attempt to access saves with empty slot")
	S.cd = "/character[slot]"

	S["version"] << SAVEFILE_VERSION_MAX // load_character will sanitize any bad data, so assume up-to-date.

	//Character
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
