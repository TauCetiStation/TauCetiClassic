/datum/holiday/valentines
	name = VALENTINES
	begin_day = 14
	end_day = 15
	begin_month = FEBRUARY

	staffwho_group_name = list(
		SW_ADMINS     = "Cherubs",
		SW_MENTORS    = "Cupids",
		SW_XENOVISORS = "Xeno-lovers",
		SW_DEVELOPERS = "Love-makers",
	)
	staffwho_prefixs = list("Loving", "adorable", "Thoughtful", "ERP", "Amiable", "Amorous", "Horny", "Devoted", "Sentimental", "Adoring", "Warmhearted", "Charming", "Beautiful", "Tenderhearted", "Enchanting", "Romantic", "Intimate", "Incel", "Loner")
	staffwho_no_staff = "THERE IS NO LOVE HERE"

/datum/holiday/valentines/greet()
	return "Happy Valentine’s Day!"


/datum/holiday/valentines/getStationPrefix()
	return pick("Love","Amore","Single","Smootch","Hug")

/datum/holiday/birthday
	name = "Birthday of Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YYYY")) - 2003
	var/Fact
	switch(game_age)
		if(16)
			Fact = " SS13 is now old enough to drive!"
		if(18)
			Fact = " SS13 is now legal!"
		if(21)
			Fact = " SS13 can now drink!"
		if(26)
			Fact = " SS13 can now rent a car!"
		if(30)
			Fact = " SS13 can now go home and be a family man!"
		if(35)
			Fact = " SS13 can now run for President of the United States!"
		if(40)
			Fact = " SS13 can now suffer a midlife crisis!"
		if(50)
			Fact = " Happy golden anniversary!"
		if(65)
			Fact = " SS13 can now start thinking about retirement!"
	if(!Fact)
		Fact = " SS13 is now [game_age] years old!"

	return "Say 'Happy Birthday' to Space Station 13, first publicly playable on February 16th, 2003![Fact]"

/datum/holiday/random_kindness
	name = "Random Acts of Kindness Day"
	begin_day = 17
	begin_month = FEBRUARY

/datum/holiday/random_kindness/greet()
	return "Go do some random acts of kindness for a stranger!"

/datum/holiday/leap
	name = "Leap Day"
	begin_day = 29
	begin_month = FEBRUARY
