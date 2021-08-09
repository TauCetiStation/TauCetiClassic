/datum/mood_event/naked
	description = "<span class='warning'>I am naked... And the worst part, people are noticing it!</span>\n"
	mood_change = -10
	timeout = 1 MINUTE

/datum/mood_event/dirty_clothes
	description = "<span class='warning'>I don't like wearing dirty clothes...</span>\n"
	mood_change = -1

/datum/mood_event/dirty_clothes/add_effects(_mood_change)
	mood_change = _mood_change

/datum/mood_event/wet_clothes
	description = "<span class='warning'>I don't like wearing wet clothes...</span>\n"
	mood_change = -1

/datum/mood_event/wet_clothes/add_effects(_mood_change)
	mood_change = _mood_change

// ipc and other synths
/datum/mood_event/dangerous_clothes
	description = "<span class='warning'>I am pretty sure these wet clothes are dangerous to me...</span>\n"
	mood_change = -2

/datum/mood_event/dangerous_clothes/add_effects(_mood_change)
	mood_change = _mood_change

// skrells and dionaea I guess
/datum/mood_event/refreshing_clothes
	description = "<span class='nicegreen'>Ah yes, nothing better than refreshing, wet clothes!</span>\n"
	mood_change = 1

/datum/mood_event/refreshing_clothes/add_effects(_mood_change)
	mood_change = _mood_change

/datum/mood_event/slipped
	description = "<span class='warning'>I slipped. I should be more careful next time...</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/on_fire
	description = "<span class='boldwarning'>I'M ON FIRE!!!</span>\n"
	mood_change = -12

/datum/mood_event/suffocation
	description = "<span class='boldwarning'>CAN'T... BREATHE...</span>\n"
	mood_change = -12

/datum/mood_event/cold
	description = "<span class='warning'>It's way too cold in here.</span>\n"
	mood_change = -5

/datum/mood_event/hot
	description = "<span class='warning'>It's getting hot in here.</span>\n"
	mood_change = -5

/datum/mood_event/self_tending
	description = "<span class='warning'>I had to tend my own wounds, is there nobody else to help me?</span>\n"
	mood_change = -3
	timeout = 1 MINUTE
