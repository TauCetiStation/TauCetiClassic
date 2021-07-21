/datum/holiday/ianbirthday
	name = "Ian's Birthday" //github.com/tgstation/tgstation/commit/de7e4f0de0d568cd6e1f0d7bcc3fd34700598acb
	begin_month = SEPTEMBER
	begin_day = 9
	end_day = 10

/datum/holiday/ianbirthday/greet()
	return "Happy birthday, Ian!"

/datum/holiday/ianbirthday/getStationPrefix()
	return pick("Ian", "Corgi", "Lisa")

/datum/holiday/programmers
	name = "Programmers' Day"

/datum/holiday/programmers/shouldCelebrate(dd, mm, yyyy, ddd) //Programmer's day falls on the 2^8th day of the year
	if(mm == SEPTEMBER)
		if(yyyy/4 == round(yyyy/4)) //Note: Won't work right on September 12th, 2200 (at least it's a Friday!)
			if(dd == 12)
				return TRUE
		else
			if(dd == 13)
				return TRUE
	return FALSE

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","EVENT PREFIX NOT FOUND") //Portability

/datum/holiday/pirate
	name = "Talk-Like-a-Pirate Day"
	begin_day = 19
	begin_month = SEPTEMBER

/datum/holiday/pirate/greet()
	return "Ye be talkin' like a pirate today or else ye'r walkin' tha plank, matey!"

/datum/holiday/pirate/getStationPrefix()
	return pick("Yarr","Scurvy","Yo-ho-ho")
