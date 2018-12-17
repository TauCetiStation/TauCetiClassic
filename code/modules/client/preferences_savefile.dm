//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 8

//This is the current version, anything below this will attempt to update (if it's not obsolete)
#define SAVEFILE_VERSION_MAX 19

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

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 17)
		for(var/organ_name in organ_data)
			if(organ_name in list("r_hand", "l_hand", "r_foot", "l_foot"))
				organ_data -= organ_name
				S["organ_data"] -= organ_name
	if(current_version < 18)
		ResetJobs()

		if(language && species && language != "None")
			if(!istext(language))
				var/atom/A = language
				language = A.name

			var/datum/language/lang = all_languages[language]
			if(!(species in lang.allowed_species))
				language = "None"
				S["language"] << language

/datum/preferences/proc/load_path(ckey, filename = "preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"

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

	//Account data
	S["cid_list"]			>> cid_list
	S["ignore_cid_warning"]	>> ignore_cid_warning

	//General preferences
	S["ooccolor"]			>> ooccolor
	S["aooccolor"]			>> aooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	S["default_slot"]		>> default_slot
	S["chat_toggles"]		>> chat_toggles
	S["toggles"]			>> toggles
	S["ghost_orbit"]		>> ghost_orbit
	S["randomslot"]			>> randomslot
	S["UI_style_color"]		>> UI_style_color
	S["UI_style_alpha"]		>> UI_style_alpha
	S["permamuted"]			>> permamuted
	S["permamuted"]			>> muted

	//Antag preferences
	S["be_role"]			>> be_role

	//*** FOR FUTURE UPDATES, SO YOU KNOW WHAT TO DO ***//
	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S) // needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	aooccolor		= sanitize_hexcolor(aooccolor, initial(aooccolor))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight","Orange","old"), initial(UI_style))
	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles		= sanitize_integer(toggles, 0, 65535, initial(toggles))
	chat_toggles	= sanitize_integer(chat_toggles, 0, 65535, initial(chat_toggles))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, ghost_orbits, initial(ghost_orbit))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	if(!cid_list)
		cid_list = list()
	ignore_cid_warning = sanitize_integer(ignore_cid_warning, 0, 1, initial(ignore_cid_warning))
	return 1

/datum/preferences/proc/save_preferences()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	S["version"] << SAVEFILE_VERSION_MAX

	//Account data
	S["cid_list"]			<< cid_list
	S["ignore_cid_warning"]	<< ignore_cid_warning

	//general preferences
	S["ooccolor"]			<< ooccolor
	S["aooccolor"]			<< aooccolor
	S["lastchangelog"]		<< lastchangelog
	S["UI_style"]			<< UI_style
	S["be_role"]			<< be_role
	S["default_slot"]		<< default_slot
	S["toggles"]			<< toggles
	S["chat_toggles"]		<< chat_toggles
	S["ghost_orbit"]		<< ghost_orbit
	S["randomslot"]			<< randomslot
	S["permamuted"]			<< permamuted
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
	S["OOC_Notes"]			>> metadata
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["gender"]				>> gender
	S["age"]				>> age
	S["species"]			>> species
	S["language"]			>> language

	//colors to be consolidated into hex strings (requires some work with dna code)
	S["hair_red"]			>> r_hair
	S["hair_green"]			>> g_hair
	S["hair_blue"]			>> b_hair
	S["facial_red"]			>> r_facial
	S["facial_green"]		>> g_facial
	S["facial_blue"]		>> b_facial
	S["skin_tone"]			>> s_tone
	S["skin_red"]			>> r_skin
	S["skin_green"]			>> g_skin
	S["skin_blue"]			>> b_skin
	S["hair_style_name"]	>> h_style
	S["facial_style_name"]	>> f_style
	S["eyes_red"]			>> r_eyes
	S["eyes_green"]			>> g_eyes
	S["eyes_blue"]			>> b_eyes
	S["underwear"]			>> underwear
	S["undershirt"]			>> undershirt
	S["socks"]				>> socks
	S["backbag"]			>> backbag
	S["b_type"]				>> b_type

	//Jobs
	S["alternate_option"]	>> alternate_option
	S["job_civilian_high"]	>> job_civilian_high
	S["job_civilian_med"]	>> job_civilian_med
	S["job_civilian_low"]	>> job_civilian_low
	S["job_medsci_high"]	>> job_medsci_high
	S["job_medsci_med"]		>> job_medsci_med
	S["job_medsci_low"]		>> job_medsci_low
	S["job_engsec_high"]	>> job_engsec_high
	S["job_engsec_med"]		>> job_engsec_med
	S["job_engsec_low"]		>> job_engsec_low

	//Miscellaneous
	S["flavor_text"]		>> flavor_text
	S["med_record"]			>> med_record
	S["sec_record"]			>> sec_record
	S["gen_record"]			>> gen_record
	S["be_role"]			>> be_role
	S["disabilities"]		>> disabilities
	S["player_alt_titles"]	>> player_alt_titles
	S["organ_data"]			>> organ_data
	S["gear"]				>> gear
	S["custom_items"]		>> custom_items

	S["nanotrasen_relation"] >> nanotrasen_relation
	S["home_system"] 		>> home_system
	S["citizenship"] 		>> citizenship
	S["faction"] 			>> faction
	S["religion"] 			>> religion
	S["parallax"]			>> parallax
	S["uplinklocation"] 	>> uplinklocation

	S["UI_style_color"]		>> UI_style_color
	S["UI_style_alpha"]		>> UI_style_alpha

	//*** FOR FUTURE UPDATES, SO YOU KNOW WHAT TO DO ***//
	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S) // needs_update == savefile_version if we need an update (positive integer)

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= sanitize_name(real_name)
	if(isnull(species)) species = HUMAN
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(!real_name) real_name = random_name(gender)
	if(!gear) gear = list()
	if(!custom_items) custom_items = list()
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	r_skin			= sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin			= sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin			= sanitize_integer(b_skin, 0, 255, initial(b_skin))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	undershirt		= sanitize_integer(undershirt, 1, undershirt_t.len, initial(undershirt))
	socks			= sanitize_integer(socks, 1, socks_t.len, initial(socks))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	b_type			= sanitize_text(b_type, initial(b_type))
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, PARALLAX_HIGH)
	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_civilian_high = sanitize_integer(job_civilian_high, 0, 65535, initial(job_civilian_high))
	job_civilian_med = sanitize_integer(job_civilian_med, 0, 65535, initial(job_civilian_med))
	job_civilian_low = sanitize_integer(job_civilian_low, 0, 65535, initial(job_civilian_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))

	if(isnull(disabilities)) disabilities = 0
	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()
	if(!be_role) src.be_role = list()

	if(!home_system) home_system = "None"
	if(!citizenship) citizenship = "None"
	if(!faction)     faction =     "None"
	if(!religion)    religion =    "None"

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
	for(var/i = 1 to MAX_SAVE_SLOTS)
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
	slot = sanitize_integer(slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
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

	S["version"]			<< SAVEFILE_VERSION_MAX // load_character will sanitize any bad data, so assume up-to-date.

	//Character
	S["OOC_Notes"]			<< metadata
	S["real_name"]			<< real_name
	S["name_is_always_random"] << be_random_name
	S["gender"]				<< gender
	S["age"]				<< age
	S["species"]			<< species
	S["language"]			<< language
	S["hair_red"]			<< r_hair
	S["hair_green"]			<< g_hair
	S["hair_blue"]			<< b_hair
	S["facial_red"]			<< r_facial
	S["facial_green"]		<< g_facial
	S["facial_blue"]		<< b_facial
	S["skin_tone"]			<< s_tone
	S["skin_red"]			<< r_skin
	S["skin_green"]			<< g_skin
	S["skin_blue"]			<< b_skin
	S["hair_style_name"]	<< h_style
	S["facial_style_name"]	<< f_style
	S["eyes_red"]			<< r_eyes
	S["eyes_green"]			<< g_eyes
	S["eyes_blue"]			<< b_eyes
	S["underwear"]			<< underwear
	S["undershirt"]			<< undershirt
	S["socks"]				<< socks
	S["backbag"]			<< backbag
	S["b_type"]				<< b_type

	//Jobs
	S["alternate_option"]	<< alternate_option
	S["job_civilian_high"]	<< job_civilian_high
	S["job_civilian_med"]	<< job_civilian_med
	S["job_civilian_low"]	<< job_civilian_low
	S["job_medsci_high"]	<< job_medsci_high
	S["job_medsci_med"]		<< job_medsci_med
	S["job_medsci_low"]		<< job_medsci_low
	S["job_engsec_high"]	<< job_engsec_high
	S["job_engsec_med"]		<< job_engsec_med
	S["job_engsec_low"]		<< job_engsec_low

	//Miscellaneous
	S["flavor_text"]		<< flavor_text
	S["med_record"]			<< med_record
	S["sec_record"]			<< sec_record
	S["gen_record"]			<< gen_record
	S["player_alt_titles"]		<< player_alt_titles
	S["be_role"]			<< be_role
	S["disabilities"]		<< disabilities
	S["organ_data"]			<< organ_data
	S["gear"]				<< gear
	S["custom_items"]		<< custom_items

	S["nanotrasen_relation"] << nanotrasen_relation
	S["home_system"] 		<< home_system
	S["citizenship"] 		<< citizenship
	S["faction"] 			<< faction
	S["religion"] 			<< religion
	S["parallax"]			<< parallax
	S["uplinklocation"] << uplinklocation

	S["UI_style_color"]		<< UI_style_color
	S["UI_style_alpha"]		<< UI_style_alpha

	return 1

#undef SAVEFILE_TOO_OLD
#undef SAVEFILE_UP_TO_DATE
#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
