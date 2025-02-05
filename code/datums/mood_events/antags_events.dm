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

/datum/mood_event/heretic
	description = "<span class='heretic'>THE HIGHER I RISE, THE MORE I SEE.</span>"
	mood_change = 100
	special_screen_obj = "mood_happiness_good"
	hidden = TRUE

/datum/mood_event/gates_of_mansus
	description = "I HAD A GLIMPSE OF THE HORROR BEYOND THIS WORLD. REALITY UNCOILED BEFORE MY EYES!"
	mood_change = -25
	timeout = 4 MINUTES

/datum/mood_event/eldritch_painting
	description = "I've been hearing weird laughter since cutting down that painting..."
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping
	description = "He is here!"
	mood_change = -3
	timeout = 11 SECONDS

/datum/mood_event/eldritch_painting/weeping_heretic
	description = "His suffering inspires me!"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping_withdrawal
	description = "My mind is clear. He is not here."
	mood_change = 1
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/desire_heretic
	description = "The void screams."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/desire_examine
	description = "The hunger has been fed, for now..."
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/heretic_vines
	description = "Oh what a lovely flower!"
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_examine
	description = "That painting really creeped me out."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_heretic_examine
	description = "Climb. Decay. Rust."
	mood_change = 6
	timeout = 3 MINUTES

/datum/mood_event/moon_smile
	description = "THE MOON SHOWS ME THE TRUTH AND ITS SMILE IS FACED TOWARDS ME!!!"
	mood_change = 10
	timeout = 2 MINUTES

/datum/mood_event/moon_insanity
	description = "THE MOON JUDGES AND FINDS ME WANTING!!!"
	mood_change = -3
	timeout = 5 MINUTES
