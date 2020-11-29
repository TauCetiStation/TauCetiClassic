/datum/religion/cult
	name = "Cult of Blood"
	deity_names_by_name = list(
		"Cult of Blood" = list("Nar-Sie", "The Geometer of Blood", "The One Who Sees", )
	)

	bible_info_by_name = list(
		"Cult of Blood" = /datum/bible_info/cult/blood
	)

	pews_info_by_name = list(
		"Satanism" = "dead"
	)

	altar_info_by_name = list(
		"Satanism" = "satanaltar"
	)

	carpet_dir_by_name = list(
		"Islam" = 4
	)

	max_favor = 10000

	var/datum/game_mode/cult/mode

	agent_type = /datum/building_agent/cult

/datum/religion/cult/New()
	..()
	area_types = typesof(/area/custom/cult)
	religify()

/datum/religion/cult/reset_religion()
	deity_names = deity_names_by_name[name]
	if(!deity_names)
		warning("ERROR IN SETTING UP RELIGION: [name] HAS NO DEITIES WHATSOVER. HAVE YOU SET UP RELIGIONS CORRECTLY?")
		deity_names = list("Error")

	gen_bible_info()
	gen_altar_variants()
	gen_pews_variants()
	gen_carpet_variants()
	gen_building_list()

/datum/religion/cult/setup_religions()
	global.cult_religion = src
	mode = SSticker.mode

/datum/religion/cult/proc/give_tome(mob/living/carbon/human/cultist)
	var/obj/item/weapon/storage/bible/tome/B = spawn_bible(cultist, /obj/item/weapon/storage/bible/tome)
	cultist.equip_to_slot_or_del(B, SLOT_IN_BACKPACK)
