var/global/libra_religion

/datum/religion/libra
	name = "Order of Libra"
	deity_names_by_name = list(
		"Order of Libra" = list("Stars of Libra", "Alpha Librae", "Beta Librae", "Gamma Librae")
	)

	bible_info_by_name = list(
		"Order of Libra",
	)

	emblem_info_by_name = list(
		"Order of Libra" = "libra"
	)

	altar_info_by_name = list(
		"Order of Libra" = "libraaltar"
	)

	carpet_type_by_name = list(
		"Order of Libra" = /turf/simulated/floor/carpet/cyan
	)

	decal_by_name = list(
		"Order of Libra",
	)

	binding_rites = list(
		/datum/religion_rites/standing/consent/invite,
		/datum/religion_rites/instant/communicate,
	)

	bible_type = /obj/item/weapon/storage/bible/tome
	religious_tool_type = /obj/item/weapon/claymore/religion
	symbol_icon_state = "libra"

/datum/religion/libra/setup_religions()
	all_religions += src
	global.libra_religion = src
