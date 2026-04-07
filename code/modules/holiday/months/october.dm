/datum/holiday/animal
	name = "Animal's Day"
	begin_day = 4
	begin_month = OCTOBER

/datum/holiday/animal/getStationPrefix()
	return pick("Parrot","Corgi","Cat","Pug","Goat","Fox")

/datum/holiday/smile
	name = "Smiling Day"
	begin_day = 7
	begin_month = OCTOBER

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 29
	begin_month = OCTOBER
	end_day = 2
	end_month = NOVEMBER

	// Order is important. SW_ADMINS, SW_MENTORS, SW_XENOVISORS, SW_DEVELOPERS
	staffwho_group_name = list("EvilAdmins", "Tikvyaks", "Monstervisors", "Skeletons")
	staffwho_prefixs = list("Gory", "Supernatural", "Ominous", "Wicked", "Twisted", "Creepy", "Haunted", "Unsettling", "Chilling", "Eerie", "Mysterious", "Otherworldly", "Spookish", "Spooky", "Petrifying", "Scary", "Skeletal")
	staffwho_no_staff = "No monsters in town"

/datum/holiday/halloween/greet()
	return "Have a spooky Halloween!"

/datum/holiday/halloween/getStationPrefix()
	return pick("Bone-Rattling","Mr. Bones' Own","2SPOOKY","Spooky","Scary","Skeletons")

