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
		"Christianity" = /datum/bible_info/chaplain/bible,
		"Satanism" = /datum/bible_info/chaplain/satanism,
		"Yog'Sotherie" = /datum/bible_info/chaplain/necronomicon,
		"Islam" = /datum/bible_info/chaplain/islam,
		"Scientology" = /datum/bible_info/chaplain/scientology,
		"Chaos" = /datum/bible_info/chaplain/book_of_lorgar,
		"Imperium" = /datum/bible_info/chaplain/book_of_lorgar/imperial_truth,
		"Toolboxia" = /datum/bible_info/chaplain/toolbox,
		"Science" = /datum/bible_info/chaplain/science,
		"Tecnologism" = /datum/bible_info/chaplain/techno,
		"Clownism" = /datum/bible_info/chaplain/scrapbook,
		"Buddhism" = /datum/bible_info/chaplain/bible/buddhism,
		"Atheism" = /datum/bible_info/chaplain/atheist,
	)

	// Is required to have a "Default" as a fallback.
	emblem_info_by_name = list(
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

	carpet_type_by_name = list(
		"Default" = /turf/simulated/floor/carpet,
		"Scientology" = /turf/simulated/floor/carpet/purple,
		"Science" = /turf/simulated/floor/carpet/purple,
	)

	decal_by_name = list(
		"Scientology",
		"Christianity",
		"Islam",
		"Judaism",
	)

	area_type = /area/station/civilian/chapel
	bible_type = /obj/item/weapon/storage/bible
	religious_tool_type = /obj/item/weapon/nullrod

	binding_rites = list(
		/datum/religion_rites/standing/consent/invite,
		/datum/religion_rites/instant/communicate,
	)

	style_text = "piety"
	symbol_icon_state = "nimbus"

/datum/religion/chaplain/setup_religions()
	global.chaplain_religion = src
	all_religions += src

/datum/religion/chaplain/create_default()
	name = pick(DEFAULT_RELIGION_NAMES)
	..()

/datum/religion/chaplain/proc/gen_pos_bible_variants()
	var/list/variants = list()
	for(var/info_type in subtypesof(/datum/bible_info/chaplain))
		var/datum/bible_info/BB = new info_type(src)
		if(!BB.name || !BB.icon_state)
			continue
		variants["[BB.name] ([BB.icon_state])"] = BB
	return variants

/datum/religion/chaplain/proc/create_by_chaplain(mob/living/carbon/human/chaplain)
	reset_religion()

	add_member(chaplain, HOLY_ROLE_HIGHPRIEST)

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

	lore = sanitize_safe(input(chaplain, "You can come up with the lore of your god in [new_religion] religion.", "Lore for new god", ""), MAX_MESSAGE_LEN)

	chaplain.equip_to_slot_or_del(B, SLOT_L_HAND)

	var/list/bible_variants = gen_pos_bible_variants()

	var/list/bible_skins = list()

	for(var/bible_info_name in bible_variants)
		var/datum/bible_info/BI = bible_variants[bible_info_name]
		bible_skins[bible_info_name] = BI.radial_image

	var/accepted = FALSE
	var/choose_timeout = world.time + 1 MINUTE
	var/new_book_style = bible_info.name

	while(!accepted)
		if(!B)
			break // prevents possible runtime errors
		new_book_style = show_radial_menu(chaplain, chaplain, bible_skins, tooltips = TRUE)

		var/datum/bible_info/BB = bible_variants[new_book_style]
		if(!BB)
			break

		BB.apply_visuals_to(B)
		bible_info = BB

		B.update_inv_mob() // so that it updates the bible's item_state in his hand

		var/like = show_radial_menu(chaplain, chaplain, radial_question, tooltips = TRUE)
		if(!like)
			break

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
	religify(null, null, chaplain)
