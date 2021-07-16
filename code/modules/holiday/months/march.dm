
/datum/holiday/pi
	name = "Pi Day"
	begin_day = 14
	begin_month = MARCH

/datum/holiday/pi/getStationPrefix()
	return pick("Sine","Cosine","Tangent","Secant", "Cosecant", "Cotangent")

/datum/holiday/st_patrick
	name = "St. Patrick's Day"
	begin_day = 17
	begin_month = MARCH

/datum/holiday/st_patrick/getStationPrefix()
	return pick("Blarney","Green","Leprechaun","Booze")

/datum/holiday/st_patrick/greet()
	return "Happy National Inebriation Day!"
