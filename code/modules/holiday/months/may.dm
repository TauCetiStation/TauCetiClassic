/datum/holiday/labor
	name = "Labor Day"
	begin_day = 1
	begin_month = MAY

/datum/holiday/firefighter
	name = "Firefighter's Day"
	begin_day = 4
	begin_month = MAY

/datum/holiday/firefighter/getStationPrefix()
	return pick("Burning","Blazing","Plasma","Fire")

/datum/holiday/bee
	name = "Bee Day"
	begin_day = 20
	begin_month = MAY

/datum/holiday/bee/getStationPrefix()
	return pick("Bee","Honey","Hive","Africanized","Mead","Buzz")
