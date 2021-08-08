//nutrition
/datum/mood_event/fat
	description = "<span class='warning'><B>I'm so fat...</B></span>\n" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "<span class='nicegreen'>I'm stuffed!</span>\n"
	mood_change = 8

/datum/mood_event/fed
	description = "<span class='nicegreen'>I have recently had some food.</span>\n"
	mood_change = 5

/datum/mood_event/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>\n"
	mood_change = -6

/datum/mood_event/starving
	description = "<span class='boldwarning'>I'm starving!</span>\n"
	mood_change = -10

//pain
/datum/mood_event/mild_pain
	description = "<span class='warning'>I'm in pain.</span>\n"
	mood_change = -2

/datum/mood_event/moderate_pain
	description = "<span class='warning'>It hurts so much!</span>\n"
	mood_change = -4

/datum/mood_event/intense_pain
	description = "<span class='warning'>The pain is excrutiating!</span>\n"
	mood_change = -6

/datum/mood_event/unspeakable_pain
	description = "<span class='boldwarning'>Please, just end the pain!</span>\n"
	mood_change = -12

/datum/mood_event/agony
	description = "<span class='boldwarning'>You feel like you could die any moment now.</span>\n"
	mood_change = -20
