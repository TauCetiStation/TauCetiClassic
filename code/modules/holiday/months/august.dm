/datum/holiday/beer
	name = "Beer Day"
	begin_day = 5
	begin_month = AUGUST

	staffwho_group_name = list(
		SW_ADMINS     = "AlcoAdmins",
		SW_MENTORS    = "Boozer",
		SW_XENOVISORS = "Beer-watchers",
		SW_DEVELOPERS = "Brewmasters",
	)
	staffwho_prefixs = list("Drunk", "Shitfaced", "Intoxicated", "Stoned", "Puking", "Depressed", "Sober", "ZOSNIK", "Wet", "Dying", "Sleeping", "Only one drink", "Inebriated", "Rummy", "Too drunk", "Alive?", "Beer-lover", "Brewr")
	staffwho_no_staff = "No beer left"

/datum/holiday/beer/greet()
	return "Beer is proof that God loves us – Ben Franklin"
