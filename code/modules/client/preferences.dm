//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()

var/const/MAX_SAVE_SLOTS = 10

#define MAX_GEAR_COST 5
#define MAX_GEAR_COST_SUPPORTER MAX_GEAR_COST+3
/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/savefile_version = 0

	//non-preference stuff
	var/permamuted = 0
	var/muted = 0
	var/last_ip
	var/last_id
	var/menu_type = "general"
	var/submenu_type = "body"
	var/list/ignore_question = list()		//For roles which getting player_saves with question system

	//account data
	var/list/cid_list = list()
	var/ignore_cid_warning = 0

	//game-preferences
	var/UI_style = null
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/aooccolor = "#b82e00"
	var/ooccolor = "#002eb8"
	var/toggles = TOGGLES_DEFAULT
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/chat_ghostsight = CHAT_GHOSTSIGHT_ALL
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/lastchangelog = ""              //Saved changlog filesize to detect if there was a change

	//sound volume preferences
	var/snd_music_vol = 100
	var/snd_ambient_vol = 100
	var/snd_effects_master_vol = 100
	var/snd_effects_voice_announcement_vol = 100
	var/snd_effects_misc_vol = 100
	var/snd_effects_instrument_vol = 100
	var/snd_notifications_vol = 100
	var/snd_admin_vol = 100
	var/snd_jukebox_vol = 100

	//antag preferences
	var/list/be_role = list()
	var/uplinklocation = "PDA"

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/b_type = "A+"					//blood type (not-chooseable)
	var/underwear = 1					//underwear type
	var/undershirt = 1					//undershirt type
	var/socks = 1						//socks type
	var/backbag = 2						//backpack type
	var/use_skirt = FALSE				//using skirt uniform version
	var/h_style = "Bald"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/grad_style = "none"				//Gradient style
	var/r_grad = 0						//Gradient color
	var/g_grad = 0						//Gradient color
	var/b_grad = 0						//Gradient color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color
	var/s_tone = 0						//Skin tone
	var/r_skin = 0						//Skin color
	var/g_skin = 0						//Skin color
	var/b_skin = 0						//Skin color
	var/r_eyes = 0						//Eye color
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = HUMAN
	var/language = "None"				//Secondary language

	//Some faction information.
	var/home_system = "None"            //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "None"               //Religious association.
	var/nanotrasen_relation = "Neutral"

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = RETURN_TO_LOBBY

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()
	var/ipc_head = "Default"

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""

	// Quirk list
	var/list/positive_quirks = list()
	var/list/negative_quirks = list()
	var/list/neutral_quirks = list()
	var/list/all_quirks = list()
	var/list/character_quirks = list()

	var/list/allowed_quirks = list()

	// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0
	// jukebox volume
	var/volume = 100
	var/parallax = PARALLAX_HIGH
	var/ambientocclusion = TRUE
	var/parallax_theme = PARALLAX_THEME_CLASSIC

  //custom loadout
	var/list/gear = list()
	var/gear_tab = "General"
	var/list/custom_items = list()

/datum/preferences/New(client/C)
	parent = C
	UI_style = global.available_ui_styles[1]
	b_type = random_blood_type()
	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			if(load_preferences())
				if(load_character())
					return
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender)

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)	return
	update_preview_icon()

	var/dat = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head>"
	dat += "<body link='#045EBE' vlink='045EBE' alink='045EBE'><center>"
	dat += "<style type='text/css'><!--A{text-decoration:none}--></style>"
	dat += "<style type='text/css'>a.white, a.white:link, a.white:visited, a.white:active{color: #40628a;text-decoration: none;background: #ffffff;border: 1px solid #161616;padding: 1px 4px 1px 4px;margin: 0 2px 0 0;cursor:default;}</style>"
	dat += "<style type='text/css'>a.white:hover{background: #dddddd}</style>"
	dat += "<style>body{background-image:url('dossier_empty.png');background-color: #F5ECDD;background-repeat:no-repeat;background-position:center top;}</style>"
	dat += "<style>.main_menu{margin-left:150px;margin-top:135px}</style>"

	if(path)
		dat += "<div class='main_menu'>"
		dat += "Slot: <b>[real_name]</b> - "
		dat += "[menu_type=="load_slot"?"<b>Load slot</b>":"<a href=\"byond://?src=\ref[user];preference=load_slot\">Load slot</a>"] - "
		dat += "<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a><br>"
		dat += "[menu_type=="general"?"<b>General</b>":"<a href=\"byond://?src=\ref[user];preference=general\">General</a>"] - "
		dat += "[menu_type=="occupation"?"<b>Occupation</b>":"<a href=\"byond://?src=\ref[user];preference=occupation\">Occupation</a>"] - "
		dat += "[menu_type=="roles"?"<b>Roles</b>":"<a href=\"byond://?src=\ref[user];preference=roles\">Roles</a>"] - "
		dat += "[menu_type=="glob"?"<b>Global</b>":"<a href=\"byond://?src=\ref[user];preference=glob\">Global</a>"] - "
		dat += "[menu_type=="loadout"?"<b>Loadout</b>":"<a href=\"byond://?src=\ref[user];preference=loadout\">Loadout</a>"] - "
		dat += "[menu_type=="quirks"?"<b>Quirks</b>":"<a href=\"byond://?src=\ref[user];preference=quirks\">Quirks</a>"] - "
		dat += "[menu_type=="fluff"?"<b>Fluff</b>":"<a href=\"byond://?src=\ref[user];preference=fluff\">Fluff</a>"]"
		dat += "<br><a href='?src=\ref[user];preference=close\'><b><font color='#FF4444'>Close</font></b></a>"
		dat += "</div>"
	else
		dat += "Please create an account to save your preferences."

	dat += "</center><hr width='535'>"
	switch(menu_type)
		if("general")
			dat += ShowGeneral(user)
		if("occupation")
			dat += ShowOccupation(user)
		if("roles")
			dat += ShowRoles(user)
		if("glob")
			dat += ShowGlobal(user)
		if("load_slot")
			dat += ShowLoadSlot(user)
		if("loadout")
			dat += ShowCustomLoadout(user)
		if("quirks")
			dat += ShowQuirks(user)
		if("fluff")
			dat += ShowFluffMenu(user)

	dat += "</body></html>"

	winshow(user, "preferences_window", TRUE)
	user << browse(dat, "window=preferences_browser")

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)
		return

	if(href_list["preference"] == "close")
		user << browse(null, "window=preferences_window")
		var/client/C = user.client
		if(C)
			C.clear_character_previews()
		return

	if(!isnewplayer(user))
		return

	switch(href_list["preference"])
		if("save")
			save_preferences()
			save_character()

		if("reload")
			load_preferences()
			load_character()

		if("changeslot")
			load_character(text2num(href_list["num"]))

		if("general")
			menu_type = "general"

		if("occupation")
			menu_type = "occupation"

		if("roles")
			menu_type = "roles"

		if("glob")
			menu_type = "glob"

		if("loadout")
			menu_type = "loadout"

		if("quirks")
			menu_type = "quirks"

		if("fluff")
			menu_type = "fluff"

		if("load_slot")
			if(!IsGuestKey(user.key))
				menu_type = "load_slot"
	switch(menu_type)
		if("general")
			process_link_general(user, href_list)

		if("occupation")
			process_link_occupation(user, href_list)

		if("roles")
			process_link_roles(user, href_list)

		if("glob")
			process_link_glob(user, href_list)

		if("loadout")
			process_link_loadout(user, href_list)

		if("quirks")
			process_link_quirks(user, href_list)

		if("fluff")
			process_link_fluff(user, href_list)
			return 1

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, icon_updates = 1)
	if(be_random_name)
		real_name = random_name(gender)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

	character.real_name = real_name
	character.name = character.real_name
	if(character.dna)
		character.dna.real_name = character.real_name

	character.flavor_text = flavor_text
	character.metadata = metadata
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.gender = gender
	character.age = age
	character.b_type = b_type

	if(species == IPC)
		qdel(character.bodyparts_by_name[BP_HEAD])
		switch(ipc_head)
			if("Default")
				new /obj/item/organ/external/head/robot/ipc(null, character)
			if("Alien")
				new /obj/item/organ/external/head/robot/ipc/alien(null, character)
			if("Double")
				new /obj/item/organ/external/head/robot/ipc/double(null, character)
			if("Pillar")
				new /obj/item/organ/external/head/robot/ipc/pillar(null, character)
			if("Human")
				new /obj/item/organ/external/head/robot/ipc/human(null, character)

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.r_grad = r_grad
	character.g_grad = g_grad
	character.b_grad = b_grad

	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.s_tone = s_tone

	character.h_style = h_style
	character.grad_style = grad_style
	character.f_style = f_style

	character.home_system = home_system
	character.citizenship = citizenship
	character.personal_faction = faction
	character.religion = religion

	// Destroy/cyborgize bodyparts & organs

	for(var/name in organ_data)
		var/obj/item/organ/external/BP = character.bodyparts_by_name[name]
		var/obj/item/organ/internal/IO = character.organs_by_name[name]
		var/status = organ_data[name]

		if(status == "amputated" && BP)
			qdel(BP) // Destroy will handle everything
		if(status == "cyborg" && BP)
			var/zone = BP.body_zone
			qdel(BP)
			switch(zone)
				if(BP_L_ARM)
					new /obj/item/organ/external/l_arm/robot(null, character)
				if(BP_R_ARM)
					new /obj/item/organ/external/r_arm/robot(null, character)
				if(BP_L_LEG)
					new /obj/item/organ/external/l_leg/robot(null, character)
				if(BP_R_LEG)
					new /obj/item/organ/external/r_leg/robot(null, character)
		if(status == "assisted" && IO)
			IO.mechassist()
		else if(status == "mechanical" && IO)
			IO.mechanize()

		else continue

	// Apply skin color
	character.apply_recolor()

	// Wheelchair necessary?
	var/obj/item/organ/external/l_leg = character.bodyparts_by_name[BP_L_LEG]
	var/obj/item/organ/external/r_leg = character.bodyparts_by_name[BP_R_LEG]
	if(!l_leg && !r_leg) // TODO cane if its only single leg.
		var/obj/structure/stool/bed/chair/wheelchair/W = new /obj/structure/stool/bed/chair/wheelchair (character.loc)
		character.buckled = W
		character.update_canmove()
		W.dir = character.dir
		W.buckled_mob = character
		W.add_fingerprint(character)

	if(underwear > underwear_m.len || underwear < 1)
		underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES
	character.underwear = underwear

	if(undershirt > undershirt_t.len || undershirt < 1)
		undershirt = 0
	character.undershirt = undershirt

	if(socks > socks_t.len || socks < 1)
		socks = 0

	character.socks = socks

	if(backbag > 5 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag
	character.use_skirt = use_skirt

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			character.gender = MALE

	if(icon_updates)
		character.update_body()
		character.update_hair()

