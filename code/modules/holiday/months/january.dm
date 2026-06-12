/datum/holiday/christmas
	name = "Christmas"
	begin_day = 7
	begin_month = JANUARY

	// Order is important. SW_ADMINS, SW_MENTORS, SW_XENOVISORS, SW_DEVELOPERS
	staffwho_group_name = list("Elf-Admins", "Snowmans", "Beastvisors", "Reindeers")
	staffwho_prefixs = list("Angelic", "Chilly", "Freezing", "Snowy", "Fun filled", "Icy", "Triumphant", "Whimsical", "Chilling", "Warmhearted", "Charming", "Beautiful", "Adorable", "Elegant", "Lovely", "Elf", "Deer")
	staffwho_no_staff = "Santa`s sleigh is nowhere to be seen"

/datum/holiday/christmas/greet()
	return "Have a merry Christmas!"
