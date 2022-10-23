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

/datum/mood_event/changeling
	description = "<span class='shadowling'>I am a monster from beyond the stars. Anything human is alien to me.</span>"
	mood_change = 100
	special_screen_obj = "mood_alien"
	hidden = TRUE

/datum/mood_event/abductor
	description = "<span class='shadowling'>I am the supreme being. My perfect mind doesn't need emotions.</span>"
	mood_change = 100
	special_screen_obj = "mood_alien"
	hidden = TRUE
