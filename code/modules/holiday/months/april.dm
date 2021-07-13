/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_month = APRIL
	begin_day = 1

/datum/holiday/spess
	name = "Cosmonautics Day"
	begin_day = 12
	begin_month = APRIL

/datum/holiday/spess/greet()
	return "On this day over [round(game_year - 1961, 100)] years ago, Comrade Yuri Gagarin first ventured into space!"

/datum/holiday/fourtwenty
	name = "Four-Twenty"
	begin_day = 20
	begin_month = APRIL

/datum/holiday/fourtwenty/getStationPrefix()
	return pick("Snoop","Blunt","Toke","Dank","Cheech","Chong")

/datum/holiday/tea
	name = "National Tea Day"
	begin_day = 21
	begin_month = APRIL

/datum/holiday/tea/getStationPrefix()
	return pick("Crumpet","Assam","Oolong","Pu-erh","Sweet Tea","Green","Black")

/datum/holiday/earth
	name = "Earth Day"
	begin_day = 22
	begin_month = APRIL
