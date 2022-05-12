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

	carpet_dir_by_name = list(
		"Default" = 0,
		"Scientology" = 8,
		"Christianity" = 2,
		"Atheism" = 10,
		"Islam" = 4,
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

// This subtype is used for integrating this system with current chaplain anything.
/datum/religion/chaplain/New()
	..()
	//Radial menu
	gen_bible_variants()

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
		if(!BB.name)
			continue
		variants[BB.name] = BB
	return variants

/datum/religion/chaplain/proc/gen_bible_variants()
	bible_skins = list()
	for(var/info_type in subtypesof(/datum/bible_info/chaplain))
		var/datum/bible_info/BI = info_type
		if(!initial(BI.name))
			continue
		bible_skins[initial(BI.name)] = image(icon = initial(BI.icon), icon_state = initial(BI.icon_state))

/datum/religion/chaplain/proc/create_by_chaplain(mob/living/carbon/human/chaplain)
	reset_religion()

	add_member(chaplain, HOLY_ROLE_HIGHPRIEST)
	var/deity_names = "Оракул"
	var/new_deity = sanitize_safe(deity_names, MAX_NAME_LEN)
	if(!new_deity)
		new_deity = deity_names
	else
		deity_names = list(new_deity)
	name = "Эрафиянство"
	religify(null, null, chaplain)
