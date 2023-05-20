//nutrition
/datum/mood_event/fat
	description = "<span class='warning'><B>I'm so fat...</B></span>" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "<span class='nicegreen'>I'm stuffed!</span>"
	mood_change = 8

/datum/mood_event/fed
	description = "<span class='nicegreen'>I have recently had some food.</span>"
	mood_change = 5

/datum/mood_event/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>"
	mood_change = -6

/datum/mood_event/starving
	description = "<span class='boldwarning'>I'm starving!</span>"
	mood_change = -10

//pain
/datum/mood_event/mild_pain
	description = "<span class='warning'>I'm in pain.</span>"
	mood_change = -2

/datum/mood_event/moderate_pain
	description = "<span class='warning'>It hurts so much!</span>"
	mood_change = -4

/datum/mood_event/intense_pain
	description = "<span class='warning'>The pain is excrutiating!</span>"
	mood_change = -6

/datum/mood_event/unspeakable_pain
	description = "<span class='boldwarning'>Please, just end the pain!</span>"
	mood_change = -12

/datum/mood_event/agony
	description = "<span class='boldwarning'>You feel like you could die any moment now.</span>"
	mood_change = -20

/datum/mood_event/lonely
	description = "<span class='warning'>I feel lonely... I better talk to somebody, for real.</span>"
	mood_change = -6

/datum/mood_event/very_lonely
	description = "<span class='boldwarning'>Am I the loneliest being in the universe?... I need to be heard!</span>"
	mood_change = -12

// Food

/datum/mood_event/junk_food
	description = "<span class='warning'>This food is hurting me!</span>"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/natural_food
	description = "<span class='nicegreen'>Very nice to eat wholesome and natural food.</span>"
	mood_change = 1
	timeout = 3 MINUTES

/datum/mood_event/tasty_food
	description = "<span class='nicegreen'>This food tastes good, I like it.</span>"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/very_tasty_food
	description = "<span class='bold nicegreen'>This food tastes just divine!</span>"
	mood_change = 4
	timeout = 5 MINUTES


//well it's bascially their need to see heads of staff i guess
/datum/mood_event/blueshield
	description = "<span class='warning'>Нужно проверить моих подопечных.</span>"
	mood_change = -6

/datum/mood_event/blueshield/add_effects()
	var/list/to_protect = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind && (player.mind.assigned_role in protected_by_blueshield_list))
			to_protect += player.mind

	if(!to_protect.len)
		mood_change = 0
		description = "<span class='notice'>А где главы?</span>"

