/datum/mood_event/area
	description = "" //Fill this out in the area
	mood_change = 0

/datum/mood_event/area/add_effects(_mood_change, _description)
	mood_change = _mood_change
	description = _description

/datum/mood_event/fresh_laundry
	description = "<span class='nicegreen'>There's nothing like the feeling of a freshly laundered jumpsuit.</span>"
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/chit_chat
	mood_change = 2
	timeout = 10 SECONDS

/datum/mood_event/chit_chat/add_effects(_speaker)
	description = "<span class='nicegreen'>I had a little chit-chat with [_speaker].</span>"

/datum/mood_event/conversation
	mood_change = 5
	timeout = 1 MINUTE

/datum/mood_event/conversation/add_effects(_speaker)
	description = "<span class='nicegreen'>I had a nice conversation with [_speaker].</span>"

/datum/mood_event/deep_conversation
	mood_change = 10
	timeout = 1 MINUTE

/datum/mood_event/deep_conversation/add_effects(_speaker)
	description = "<span class='bold nicegreen'>I just had the deepest conversation of my life with [_speaker]. Lots to ponder about...</span>"

/datum/mood_event/happiness
	mood_change = 6
	description = "<span class='bold nicegreen'>For no apparent reason I feel great! I love life!</span>"
