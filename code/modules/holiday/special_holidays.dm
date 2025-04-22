/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yyyy, ddd)
	if(dd == 13 && ddd == FRIDAY)
		return TRUE
	return FALSE

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")



#define DAYS_EARLY 1 //to make editing the holiday easier
#define DAYS_EXTRA 1
/datum/holiday/easter
	name = EASTER

/datum/holiday/easter/greet()
	return "Greetings! Have a Happy Easter and keep an eye out for Easter Bunnies!"

/datum/holiday/easter/getStationPrefix()
	return pick("Fluffy","Bunny","Easter","Egg")

/datum/holiday/easter/shouldCelebrate(dd, mm, yyyy, ddd)
	return TRUE


/* Egg Hunt */

/datum/announcement/centcomm/egghunt/pre
	name = "Egg Hunt will Start soon!"
	subtitle = "Ежегодная охота за яйцами"
	sound = "commandreport"

/datum/announcement/centcomm/egghunt/pre/New()
	message = "Исход! В рамках программы по повышению стрессоустойчивости персонала мы проводим пасхальную охоту за яйцами! " + \
			"Подготовьтесь, через минуту вам потребуется искать цветные яйца, которые мы спрятали по станции, и класть их к себе в рюкзак. " + \
			"Спустя еще 30 минут таймер подойдет к концу и будут объявлены победители!"

/datum/announcement/centcomm/egghunt/start
	name = "Egg Hunt Starts!"
	subtitle = "Ежегодная охота за яйцами"
	sound = "commandreport"

/datum/announcement/centcomm/egghunt/start/New()
	message = "Охота за яйцами началась! Они могут быть где угодно, будьте внимательны! Через 30 минут объявим победителей "

/datum/announcement/centcomm/egghunt/finish
	name = "Egg Hunt Ends!"
	subtitle = "Ежегодная охота за яйцами"
	sound = "commandreport"

/datum/announcement/centcomm/egghunt/finish/New(list/L)
	message = "Объявляем победителей охоты за яйцами! <br>"
	var/position = 0
	for(var/key in L)
		position++
		message += "<br> [position]: [key] - [L[key]] яиц. "
		if(position == 1)
			message += "Победитель!"
		else if(position == 10)
			break

/client/proc/start_egg_hunt()
	set category = "Fun"
	set name = "Start Egg Hunt"
	if(!check_rights(R_FUN))	return
	if(!SSholiday.holidays[EASTER])	return

	if(tgui_alert(usr, "Are you sure?","Confirm Egg Hunt", list("Yes", "No")) == "No")
		return

	message_admins("[key_name_admin(src)] started the Egg Hunt!")

	var/datum/holiday/easter/E = SSholiday.holidays[EASTER]
	E.egg_hunt_announce()

/datum/holiday/easter/proc/egg_hunt_announce()
	var/datum/announcement/centcomm/egghunt/pre/announcement = new
	announcement.play()

	addtimer(CALLBACK(src, PROC_REF(egg_hunt_begin)), 60 SECONDS)

/datum/holiday/easter/proc/egg_hunt_begin()
	var/datum/announcement/centcomm/egghunt/start/announcement = new
	announcement.play()

	// 4 eggs per each station area
	for(var/A in global.the_station_areas)
		var/area/R = get_area_by_type(A)
		var/max_eggs_per_area = 4
		for(var/turf/simulated/floor/T in get_area_turfs(R))
			if(max_eggs_per_area && prob(2))
				new /obj/random/foods/egg(T)
				max_eggs_per_area -= 1

	// a chance to spawn an egg in each closet
	for(var/obj/structure/closet/C in closet_list)
		if(prob(5))
			new /obj/random/foods/egg(C)

	addtimer(CALLBACK(src, PROC_REF(egg_hunt_finish)), 1800 SECONDS)

/datum/holiday/easter/proc/egg_hunt_finish()
	var/list/winners_list = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/egg_amount = 0
		if(is_station_level(H.z))
			var/list/items_to_check = H.GetAllContents()
			for(var/A in items_to_check)
				if(istype(A, /obj/item/weapon/reagent_containers/food/snacks/egg))
					egg_amount++
		winners_list[H.name] = egg_amount

	sortTim(winners_list, GLOBAL_PROC_REF(cmp_numeric_dsc), associative=TRUE)

	var/datum/announcement/centcomm/egghunt/finish/announcement = new(winners_list)
	announcement.play()



/datum/holiday/easter/celebrate()
	. = ..()
	admin_verbs_fun += /client/proc/start_egg_hunt
	global.maintenance_loot += list(
		list(
			/obj/item/weapon/reagent_containers/food/snacks/egg = 15,
		) = maint_holiday_weight,
	)

#undef DAYS_EARLY
#undef DAYS_EXTRA


//Y, eg: 2017, 2018, 2019, in num form (not string)
//etc. Between 1583 and 4099
//Adapted from a free algorithm written in BASIC (https://www.assa.org.au/edm#Computer)
/proc/EasterDate(y)
	var/FirstDig, Remain19, temp //Intermediate Results
	var/tA, tB, tC, tD, tE //Table A-E results
	var/d, m //Day and Month returned

	FirstDig = round((y / 100))
	Remain19 = y % 19

	temp = (round((FirstDig - 15) / 2)) + 202 - 11 * Remain19

	switch(FirstDig)
		if(21,24,25,27,28,29,30,31,32,34,35,38)
			temp -= 1
		if(33,36,37,39,40)
			temp -= 2
	temp %= 30

	tA = temp + 21
	if(temp == 29)
		tA -= 1
	if(temp == 28 && (Remain19 > 10))
		tA -= 1
	tB = (tA - 19) % 7

	tC = (40 - FirstDig) % 4
	if(tC == 3)
		tC += 1
	if(tC > 1)
		tC += 1
	temp = y % 100
	tD = (temp + round((temp / 4))) % 7

	tE = ((20 - tB - tC - tD) % 7) + 1
	d = tA + tE
	if(d > 31)
		d -= 31
		m = 4
	else
		m = 3
	return list("day" = d, "month" = m)
