/datum/holiday/human_rights
	name = "Human-Rights Day"
	begin_day = 10
	begin_month = DECEMBER

/datum/holiday/monkey
	name = MONKEYDAY
	begin_day = 14
	begin_month = DECEMBER

/datum/holiday/xmas
	name = "Catolic Christmas"
	begin_day = 23
	begin_month = DECEMBER
	end_day = 27

/datum/holiday/xmas/greet()
	return "Have a merry Christmas!"

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 31
	begin_month = DECEMBER
	end_day = 2
	end_month = JANUARY

/datum/holiday/new_year/getStationPrefix()
	return pick("Party","New","Hangover","Resolution", "Auld")

/datum/holiday/new_year/celebrate()
	for(var/obj/structure/flora/tree/pine/xmas in tree_xmas_list)
		if(!is_station_level(xmas.z))
			continue
		for(var/turf/simulated/floor/T in orange(1, xmas))
			for(var/i = 1, i <= rand(1, 5), i++)
				new /obj/item/weapon/a_gift(T)

	for(var/mob/living/carbon/ian/Ian in carbon_list)
		Ian.equip_to_slot_if_possible(new /obj/item/clothing/head/helmet/space/santahat(Ian), SLOT_HEAD)

/datum/holiday/boxing
	name = "Boxing Day"
	begin_day = 26
	begin_month = DECEMBER
