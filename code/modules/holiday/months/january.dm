/datum/holiday/christmas
	name = "Christmas"
	begin_day = 7
	begin_month = JANUARY

	staffwho_group_name = list(
		SW_ADMINS     = "Elf-Admins",
		SW_MENTORS    = "Snowmans",
		SW_XENOVISORS = "Beastvisors",
		SW_DEVELOPERS = "Reindeers",
	)
	staffwho_prefixs = list("Angelic", "Chilly", "Freezing", "Snowy", "Fun filled", "Icy", "Triumphant", "Whimsical", "Chilling", "Warmhearted", "Charming", "Beautiful", "Adorable", "Elegant", "Lovely", "Elf", "Deer")
	staffwho_no_staff = "Santa`s sleigh is nowhere to be seen"

/datum/holiday/christmas/greet()
	return "Have a merry Christmas!"
