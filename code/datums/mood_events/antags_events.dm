/datum/mood_event/thrall
	description = "<span class='shadowling'>Anything for my master!</span>"
	mood_change = 10

/datum/mood_event/master_died
	description = "<span class='shadowling'>My master has died. I have no reason to live anymore...</span>"
	mood_change = -15
	timeout = 15 MINUTES

/datum/mood_event/rev
	description = "<span class='bold nicegreen'>Viva la Revolucion!</span>"
	mood_change = 5
	hidden = TRUE

/datum/mood_event/narsie
	description = "<span class='bold nicegreen'>For some reason, I really want to die very much</span>"
	mood_change = -666

/datum/mood_event/narsie_cultists
	description = "<span class='bold nicegreen'>Greetings to the Lord!</span>"
	mood_change = 666
