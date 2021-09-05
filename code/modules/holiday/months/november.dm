/datum/holiday/vegan
	name = "Vegan Day"
	begin_day = 1
	begin_month = NOVEMBER

/datum/holiday/vegan/getStationPrefix()
	return pick("Tofu", "Tempeh", "Seitan", "Tofurkey")

/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER

/datum/holiday/remembrance_day
	name = "Remembrance Day"
	begin_month = NOVEMBER
	begin_day = 11

/datum/holiday/remembrance_day/getStationPrefix()
	return pick("Peace", "Armistice", "Poppy")
