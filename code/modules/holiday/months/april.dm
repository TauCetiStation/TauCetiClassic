/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_month = APRIL
	begin_day = 1

	staffwho_group_name = list(
		SW_ADMINS     = "ClownAdmins",
		SW_MENTORS    = "Mimes",
		SW_XENOVISORS = "Honkovisors",
		SW_DEVELOPERS = "Janitors",
	)
	staffwho_prefixs = list("Bored", "Boring", "Funny", "Not Funny", "Cute", "Ugly", "Evil", "Despot", "Sad", "Kind", "Smart", "Wise", "Stupid", "Dumb", "III", "Shit Spawner", "Confused", "Chaotic", "Toxic", "SSD", "Insane", "", "Golden", "Tiny", "Furry", "Holy", "Unholy", "Looser", "Foolish", "Red", "Blue", "ERP")
	staffwho_no_staff = "No Clowns Online"

/datum/holiday/april_fools/greet()
	return "Your back is white"

/datum/holiday/spess
	name = "Cosmonautics Day"
	begin_day = 12
	begin_month = APRIL

	staffwho_group_name = list(
		SW_ADMINS     = "Astronauts",
		SW_MENTORS    = "Cosmonauts",
		SW_XENOVISORS = "Space-observers",
		SW_DEVELOPERS = "Houstons",
	)
	staffwho_prefixs = list("Spaced", "Frozen", "Alien", "Comrade", "Dog", "Flying", "Galactical", "Puzzled", "Decompressed", "Amazed", "Ready", "Proud", "Space Erp", "Xenos", "Pilot", "Astronaut", "Cosmonavt")
	staffwho_no_staff = "Space is empty"

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
