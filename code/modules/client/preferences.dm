var/global/list/preferences_datums = list()

#define MAX_SAVE_SLOTS 10
#define MAX_SAVE_SLOTS_SUPPORTER MAX_SAVE_SLOTS+10
#define GET_MAX_SAVE_SLOTS(Client) ((Client && Client.supporter) ? MAX_SAVE_SLOTS_SUPPORTER : MAX_SAVE_SLOTS)

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
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/clientfps = -1

	// Custom Keybindings
	var/list/key_bindings = list()
	// If hotkey mode is enabled, then clicking the map will automatically
	// unfocus the text bar. This removes the red color from the text bar
	// so that the visual focus indicator matches reality.
	var/hotkeys = TRUE

	var/tooltip = TRUE
	var/tooltip_font = "Small Fonts"
	var/tooltip_size = 8

	var/outline_enabled = TRUE
	var/outline_color = COLOR_BLUE_LIGHT
	var/eorg_enabled = TRUE

	var/show_runechat = TRUE

	var/list/custom_emote_panel = list()

	//TGUI
	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE

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
	var/neuter_gender_voice = MALE		//for male/female emote sounds but with neuter gender
	var/age = 30						//age of character
	var/height = HUMANHEIGHT_MEDIUM		//height of character
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
	var/r_belly = 0
	var/g_belly = 0
	var/b_belly = 0
	var/species = HUMAN
	var/language = "None"				//Secondary language
	var/insurance = INSURANCE_NONE

	//Some faction information.
	var/home_system = "None"            //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "None"               //Religious association.
	var/nanotrasen_relation = "Neutral"
	var/vox_rank = "Larva"              //Vox ranks

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

	// Qualities
	// Quality selected.
	var/selected_quality_name
	var/selecting_quality = FALSE

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
	var/auto_fit_viewport = TRUE
	var/lobbyanimation = FALSE
	// lighting settings
	var/glowlevel = GLOW_MED // or bloom
	var/lampsexposure = TRUE // idk how we should name it
	var/lampsglare = FALSE // aka lens flare
	//Impacts performance clientside
	var/eye_blur_effect = TRUE

  //custom loadout
	var/list/gear = list()
	var/gear_tab = "General"
	var/list/custom_items = list()

	var/chosen_ringtone = "Flip-Flap"
	var/custom_melody = "E7,E7,E7"

/datum/preferences/New(client/C)
	parent = C
	UI_style = global.available_ui_styles[1]
	custom_emote_panel = global.emotes_for_emote_panel
	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			if(load_preferences())
				if(load_character())
					return
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender)
	key_bindings = deepCopyList(global.hotkey_keybinding_list_by_key) // give them default keybinds too
	C?.set_macros()

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)	return
	update_preview_icon()

	var/dat = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head>"
	dat += "<body link='#045EBE' vlink='045EBE' alink='045EBE'><center>"
	dat += "<style type='text/css'><!--A{text-decoration:none}--></style>"
	dat += "<style type='text/css'>a.white, a.white:link, a.white:visited, a.white:active{color: #40628a;text-decoration: none;background: #ffffff;border: 1px solid #161616;padding: 1px 4px 1px 4px;margin: 0 2px 0 0;cursor:default;}</style>"
	dat += "<style type='text/css'>a.white:hover{background: #dddddd}</style>"
	dat += "<style type='text/css'>a.disabled{background:#999999!important;text-decoration: none;border: 1px solid #161616;padding: 1px 4px 1px 4px;margin: 0 2px 0 0;cursor:default;}</style>"
	dat += "<style type='text/css'>a.fluid{display:block;margin-left:0;margin-right:0;text-align:center;}</style>"
	dat += "<style>body{background-image:url('dossier_empty.png');background-color: #F5ECDD;background-repeat:no-repeat;background-position:center top;background-attachment: fixed;}</style>"
	dat += "<style>.main_menu{margin-left:150px;margin-top:135px;}</style>"

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
		dat += "[menu_type=="fluff"?"<b>Fluff</b>":"<a href=\"byond://?src=\ref[user];preference=fluff\">Fluff</a>"] - "
		dat += "[menu_type=="custom_keybindings"?"<b>Custom Keybindings</b>":"<a href=\"byond://?src=\ref[user];preference=custom_keybindings\">Custom Keybindings</a>"]"
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
		if("custom_keybindings")
			dat += ShowCustomKeybindings(user)
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

		if("custom_keybindings")
			menu_type = "custom_keybindings"

		if("load_slot")
			if(!IsGuestKey(user.key))
				menu_type = "load_slot"

		if("open_jobban_info") //for the 'occupation' and 'roles' panels
			open_jobban_info(user, href_list["position"])
			return

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

		if("custom_keybindings")
			process_link_custom_keybindings(user, href_list)

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, icon_updates = TRUE)
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

	character.set_species(species)

	character.flavor_text = flavor_text
	character.metadata = metadata
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.gender = gender
	character.neuter_gender_voice = neuter_gender_voice
	character.age = age
	character.height = height

	character.regenerate_icons()

	if(species == IPC)
		qdel(character.bodyparts_by_name[BP_HEAD])
		switch(ipc_head)
			if("Default")
				var/obj/item/organ/external/head/robot/ipc/H = new(null)
				H.insert_organ(character)
			if("Alien")
				var/obj/item/organ/external/head/robot/ipc/alien/H = new(null)
				H.insert_organ(character)
			if("Double")
				var/obj/item/organ/external/head/robot/ipc/double/H = new(null)
				H.insert_organ(character)
			if("Pillar")
				var/obj/item/organ/external/head/robot/ipc/pillar/H = new(null)
				H.insert_organ(character)
			if("Human")
				var/obj/item/organ/external/head/robot/ipc/human/H = new(null)
				H.insert_organ(character)
		var/obj/item/organ/internal/eyes/ipc/IO = new(null)
		IO.insert_organ(character)

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.r_belly = r_belly
	character.g_belly = g_belly
	character.b_belly = b_belly

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
	character.roundstart_insurance = insurance
	character.personal_faction = faction
	character.religion = religion
	character.vox_rank = vox_rank

	// Destroy/cyborgize bodyparts & organs

	for(var/name in organ_data)
		var/obj/item/organ/external/BP = character.bodyparts_by_name[name]
		var/obj/item/organ/internal/IO = character.organs_by_name[name]
		var/status = organ_data[name]

		if(status == "amputated" && BP)
			qdel(BP)
		else if(status == "cyborg")
			if(BP)
				qdel(BP)
			switch(name)
				if(BP_L_ARM)
					var/obj/item/organ/external/l_arm/robot/R = new(null)
					R.insert_organ(character)
				if(BP_R_ARM)
					var/obj/item/organ/external/r_arm/robot/R = new(null)
					R.insert_organ(character)
				if(BP_L_LEG)
					var/obj/item/organ/external/l_leg/robot/R = new(null)
					R.insert_organ(character)
				if(BP_R_LEG)
					var/obj/item/organ/external/r_leg/robot/R = new(null)
					R.insert_organ(character)

		// create normal bodypart
		else if(status == null && character.species.has_bodypart[name] && (!BP || BP.controller_type == /datum/bodypart_controller/robot))
			var/type = character.species.has_bodypart[name]
			var/obj/item/organ/external/new_BP = new type(null)
			new_BP.insert_organ(character)

		else if(status == "assisted" && IO)
			IO.mechassist()
		else if(status == "mechanical" && IO)
			IO.mechanize()

		else
			continue

	// Apply skin color
	character.apply_recolor()

	// Wheelchair necessary?
	var/obj/item/organ/external/l_leg = character.bodyparts_by_name[BP_L_LEG]
	var/obj/item/organ/external/r_leg = character.bodyparts_by_name[BP_R_LEG]
	if(!l_leg && !r_leg) // TODO cane if its only single leg.
		var/obj/structure/stool/bed/chair/wheelchair/W = new /obj/structure/stool/bed/chair/wheelchair (character.loc)
		W.set_dir(character.dir)
		W.buckle_mob(character)

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

	if(icon_updates)
		character.update_body()
		character.update_hair()

//for the 'occupation' and 'roles' panels
/datum/preferences/proc/open_jobban_info(mob/user, rank)
	if(rank && (rank in user.client.jobbancache)) //this double-checking after the call of jobban_isbanned() can be not needed in the most cases, but we cannot trust the preceding href
		var/dat

		dat += "<b>Причина, указанная администратором:</b><br>\"[user.client.jobbancache[rank]["reason"]]\""
		dat += "<hr>"
		dat += "Выдан администратором [user.client.jobbancache[rank]["ackey"]] [user.client.jobbancache[rank]["bantime"]] "

		if(user.client.jobbancache[rank]["rid"])
			dat += "в раунде #[user.client.jobbancache[rank]["rid"]] "

		if(user.client.jobbancache[rank]["bantype"] == "JOB_TEMPBAN")
			dat += "как временный на [user.client.jobbancache[rank]["duration"]] минут. Истечёт [user.client.jobbancache[rank]["expiration"]]."
			dat += "<hr>"
			dat += "<br>"
			dat += "Дополнительную информацию можно получить у администратора, выдавшего джоббан. Апелляции и жалобы принимаются на форуме."
		else
			dat += "как бессрочный."
			dat += "<hr>"
			dat += "<br>"
			dat += "Дополнительную информацию можно получить у администратора, выдавшего бессрочный джоббан. С ним же стоит согласовывать снятие этого джоббана, если вы согласны с его выдачей. Если у вас есть не разрешаемые в личной беседе с администратором претензии или же администратор, с джоббаном от которого вы согласны, покинул состав, обратитесь на форум."

		var/datum/browser/popup = new(user, "jobban_info", "Информация о джоббане", ntheme = CSS_THEME_LIGHT)
		popup.set_content(dat)
		popup.open()
