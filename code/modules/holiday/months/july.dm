/datum/holiday/doctor
	name = "Doctor's Day"
	begin_day = 1
	begin_month = JULY

/datum/holiday/ufo
	name = "UFO Day"
	begin_day = 2
	begin_month = JULY

/datum/holiday/ufo/getStationPrefix() //Is such a thing even possible?
	return pick("Ayy","Truth","Tsoukalos","Mulder","Scully") //Yes it is!

/datum/holiday/writer
	name = "Writer's Day"
	begin_day = 8
	begin_month = JULY

/datum/holiday/friendship
	name = "Friendship Day"
	begin_day = 30
	begin_month = JULY

/datum/holiday/friendship/greet()
	return "Have a magical [name]!"

/datum/holiday/wizards_day
	name = "Wizard's Day"
	begin_month = JULY
	begin_day = 27

/datum/holiday/wizards_day/getStationPrefix()
	return pick("Dungeon", "Elf", "Magic", "D20", "Edition")
