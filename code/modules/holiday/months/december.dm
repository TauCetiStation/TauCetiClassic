/datum/holiday/human_rights
	name = "Human-Rights Day"
	begin_day = 10
	begin_month = DECEMBER



/datum/holiday/monkey
	name = MONKEYDAY
	begin_day = 14
	begin_month = DECEMBER



/datum/holiday/end_of_world
	name = "End of the World"
	begin_day = 21
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



/datum/holiday/boxing
	name = "Boxing Day"
	begin_day = 26
	begin_month = DECEMBER
