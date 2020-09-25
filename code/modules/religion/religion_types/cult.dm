/datum/religion/cult
	name = "Cult of Blood"
	deity_names_by_name = list(
		"Cult of Blood" = list("Nar-Sie", "Geometr")
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

/datum/religion/cult/New()
	..()
	gen_bible_info()
	area_types = typesof(/area/custom/cult)
	religify()

/datum/religion/cult/setup_religions()
	global.cult_religion = src

/datum/religion/cult/proc/give_tome(mob/living/carbon/human/cultist)
	var/obj/item/weapon/storage/bible/B = spawn_bible(cultist)
	bible_info.apply_to(B)

	cultist.equip_to_slot_or_del(B, SLOT_IN_BACKPACK)
