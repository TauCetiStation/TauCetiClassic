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

/datum/mood_event/happiness
	mood_change = 6
	description = "<span class='bold nicegreen'>For no apparent reason I feel great! I love life!</span>"

/datum/mood_event/drunk
	mood_change = 1
	description = "<span class='nicegreen'>Everything just feels better after a drink or two.</span>"

/datum/mood_event/very_drunk
	mood_change = 3
	description = "<span class='nicegreen'>I *hicc* do not feel my hands, what regrets?</span>"

/datum/mood_event/drunk_catharsis
	mood_change = 10
	description = "<span class='bold nicegreen'>Whatever happens - happens. I do not care any longer. Void, consume me.</span>"

/datum/mood_event/smoked
	description = "<span class='nicegreen'>I have had a smoke recently.</span>"
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/shower
	description = "<span class='nicegreen'>I've had a relaxing shower-time.</span>"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/sauna
	description = "<span class='nicegreen'>I've had a relaxing time in sauna.</span>"
	mood_change = 3
	timeout = 10 MINUTES
