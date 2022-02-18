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
	if(!begin_month)
		/// Held variable to better calculate when certain holidays may fall on, like easter.
		var/current_year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/easterResults = EasterDate(current_year)

		begin_day = easterResults["day"]
		begin_month = easterResults["month"]

		end_day = begin_day + DAYS_EXTRA
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= DAYS_EARLY
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

	return ..()

/datum/holiday/easter/celebrate()
	. = ..()
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
