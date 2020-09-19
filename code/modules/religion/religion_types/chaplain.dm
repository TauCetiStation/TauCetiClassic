/datum/religion/chaplain
	deity_names_by_name = list(
		"Christianity" = list("Lord", "God", "Saviour", "Yahweh", "Jehovah", "Father", "Space-Jesus"),
		"Satanism" = list("Satana", "Lucifer", "Baphomet", "Leviathan"),
		"Yog'Sotherie" = list("Cthulhu", "Katuluu", "Kachoochoo", "Kutulu", "The Great Dreamer", "The Sleeper of R'lyeh"),
		"Islam" = list("Allah"),
		"Scientology" = list("Xenu", "Xemu"),
		"Chaos" = list("Chaos", "Khorne", "Slaanesh", "Nurlge", "Tzeentch", "Malal"),
		"Imperium" = list("God Emperor of Mankind"),
		"Toolboxia" = list("The Toolbox"),
		"Science" = list("The Scientific Method"),
		"Technologism" = list("Omnissiah", "Machine God", "Broken God"),
		"Clownism" = list("Honkmother", "The Harlequin", "Laughing God", "First fool"),
		"Buddhism" = list("Vairocana", "Aksobhya", "Ratnasambhava", "Amoghasiddhi", "Bhaisajyaguru", "Vajradhara", "Samanthabhadra", "Tara"),
		"Atheism" = list("Self", "I"),
	)

	// Default is /datum/bible_info/custom, if one is not specified here.
	bible_info_by_name = list(
		"Christianity" = /datum/bible_info/bible,
		"Satanism" = /datum/bible_info/satanism,
		"Yog'Sotherie" = /datum/bible_info/necronomicon,
		"Islam" = /datum/bible_info/islam,
		"Scientology" = /datum/bible_info/scientology,
		"Chaos" = /datum/bible_info/book_of_lorgar,
		"Imperium" = /datum/bible_info/book_of_lorgar/imperial_truth,
		"Toolboxia" = /datum/bible_info/toolbox,
		"Science" = /datum/bible_info/science,
		"Tecnologism" = /datum/bible_info/techno,
		"Clownism" = /datum/bible_info/scrapbook,
		"Buddhism" = /datum/bible_info/bible/buddhism,
		"Atheism" = /datum/bible_info/atheist,
	)

	// Is required to have a "Default" as a fallback.
	pews_info_by_name = list(
		"Default" = "general",
		"Christianity" = "christianity",
		"Satanism" = "dead",
		"Yog'Sotherie" = "cthulhu",
		"Islam" = "islam",
		"Toolboxia" = "toolbox",
		"Science" = "science",
		"Technologism" = "singulo",
		"Clownism" = "clown",
		"Atheism" = "void",
		"Slime" = "slime",
		"NanoTrasen" = "nanotrasen",
	)

	altar_info_by_name = list(
		"Default" = "altar",
		"Christianity" = "chirstianaltar",
		"Satanism" = "satanaltar",
		"Toolboxia" = "toolboxaltar",
		"Science" = "technologyaltar",
		"NanoTrasen" = "altar",
		"Chaos" = "chaosaltar",
		"Imperium" = "imperialaltar",
		"Druid" = "druidaltar"
	)

	carpet_dir_by_name = list(
		"Default" = 0,
		"Scientology" = 8,
		"Christianity" = 2,
		"Atheism" = 10,
		"Islam" = 4,
	)

// This subtype is used for integrating this system with current chaplain anything.
/datum/religion/chaplain/New()
	..()
	religify_chapel()

	//Radial menu
	gen_bible_variants()
	gen_altar_variants()
	gen_pews_variants()
	gen_carpet_variants()
	
/datum/religion/chaplain/setup_religions()
	global.chaplain_religion = src

/datum/religion/chaplain/proc/religify_chapel()
	for(var/chap_area in typesof(/area/station/civilian/chapel))
		religify(chap_area)

/datum/religion/chaplain/proc/gen_pos_bible_variants()
	var/list/variants = list()
	for(var/info_type in subtypesof(/datum/bible_info))
		var/datum/bible_info/BB = new info_type(src)
		if(!BB.name)
			continue
		variants[BB.name] = BB
	return variants

/datum/religion/chaplain/proc/gen_bible_variants()
	bible_skins = list()
	for(var/info_type in subtypesof(/datum/bible_info))
		var/datum/bible_info/BI = info_type
		if(!initial(BI.name))
			continue
		bible_skins[initial(BI.name)] = image(icon = initial(BI.icon), icon_state = initial(BI.icon_state))

/datum/religion/chaplain/proc/gen_altar_variants()
	altar_skins = list()
	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/info in altar_info_by_name)
		var/image/I = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = altar_info_by_name[info])
		I.transform = M
		altar_skins[info] = I

/datum/religion/chaplain/proc/gen_pews_variants()
	pews_skins = list()
	for(var/info in pews_info_by_name)
		pews_skins[info] = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "[pews_info_by_name[info]]_left")

/datum/religion/chaplain/proc/gen_carpet_variants()
	carpet_skins = list()
	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/info in carpet_dir_by_name)
		var/image/I = image(icon = 'icons/turf/carpets.dmi', icon_state = "carpetsymbol", dir = carpet_dir_by_name[info])
		I.transform = M
		carpet_skins[info] = I

/datum/religion/chaplain/proc/create_by_chaplain(mob/living/carbon/human/chaplain)
	reset_religion()

	var/new_religion = sanitize_safe(input(chaplain, "You are the crew services officer. Would you like to change your religion? Default is [name], in SPACE.", "Name change", name), MAX_NAME_LEN)
	if(!new_religion)
		new_religion = name
	else
		name = new_religion
		deity_names = deity_names_by_name[name] ? deity_names_by_name[name] : list("Space-Jesus")

	feedback_set_details("religion_name","[new_religion]")

	var/deity_name = pick(deity_names)
	var/new_deity = sanitize_safe(input(chaplain, "Would you like to change your deity? Default is [deity_name].", "Name change", deity_name), MAX_NAME_LEN)
	if(!new_deity)
		new_deity = deity_name
	else
		// Currently no polyteistic support. ~Luduk
		deity_names = list(new_deity)

	gen_bible_info()

	var/obj/item/weapon/storage/bible/B = spawn_bible(chaplain)
	if(!B.god_lore)
		var/new_lore = sanitize_safe(input(chaplain, "You can come up with the lore of your god in [new_religion] religion.", "Lore for new god", ""), MAX_MESSAGE_LEN)
		B.god_lore = new_lore
		lore = new_lore

	chaplain.equip_to_slot_or_del(B, SLOT_L_HAND)

	var/list/bible_variants = gen_pos_bible_variants()

	var/accepted = FALSE
	var/choose_timeout = world.time + 1 MINUTE
	var/new_book_style = bible_info.name

	while(!accepted)
		if(!B)
			break // prevents possible runtime errors
		new_book_style = show_radial_menu(chaplain, chaplain, bible_skins, tooltips = TRUE)

		var/datum/bible_info/BB = bible_variants[new_book_style]
		if(BB)
			BB.apply_visuals_to(B)
			bible_info = BB

			chaplain.update_inv_l_hand() // so that it updates the bible's item_state in his hand

		var/like = show_radial_menu(chaplain, chaplain, radial_question, tooltips = TRUE)
		switch(like)
			if("Yes")
				accepted = TRUE
			if("No")
				if(choose_timeout <= world.time)
					to_chat(chaplain, "Welp, out of time, buddy. You're stuck. Next time choose faster.")
					accepted = TRUE

	feedback_set_details("religion_deity","[new_deity]")
	feedback_set_details("religion_book","[new_book_style]")

	// Update the looks of the chapel.
	update_structure_info()
	religify_chapel()
