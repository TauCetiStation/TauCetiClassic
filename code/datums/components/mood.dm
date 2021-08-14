/datum/component/mood
	var/mood //Real happiness
	var/spirit = SPIRIT_NEUTRAL //Current spirit
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level = 5 //To track what stage of moodies they're on
	var/spirit_level = 2 //To track what stage of spirit they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/list/datum/mood_event/mood_events = list()
	var/atom/movable/screen/mood/screen_obj

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSmood, src)

	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, .proc/add_event)
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, .proc/clear_event)
	RegisterSignal(parent, COMSIG_LIVING_REJUVENATE, .proc/on_revive)
	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)

	var/mob/living/owner = parent
	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	unmodify_hud()
	return ..()

/datum/component/mood/proc/print_mood(mob/user)
	var/msg = "<span class='info'>*---------*\n<EM>My current mental status:</EM></span>\n"
	msg += "<span class='notice'>My current spirit: </span>" //Long term
	switch(spirit)
		if(SPIRIT_HIGH to INFINITY)
			msg += "<span class='nicegreen'>My mind feels like a temple!</span>\n"
		if(SPIRIT_NEUTRAL to SPIRIT_HIGH)
			msg += "<span class='nicegreen'>I have been feeling great lately!</span>\n"
		if(SPIRIT_DISTURBED to SPIRIT_NEUTRAL)
			msg += "<span class='nicegreen'>I have felt quite decent lately.</span>\n"
		if(SPIRIT_POOR to SPIRIT_DISTURBED)
			msg += "<span class='warning'>I haven't felt good in a while.</span>\n"
		if(SPIRIT_LOW to SPIRIT_POOR)
			msg += "<span class='boldwarning'>I'm feeling a bit down.</span>\n"
		if(SPIRIT_BAD to SPIRIT_LOW)
			msg += "<span class='boldwarning'>My mind feels like a wasteland of sadness.</span>\n"

	msg += "<span class='notice'>My current mood: </span>" //Short term
	switch(mood_level)
		if(1)
			msg += "<span class='boldwarning'>I feel terribly bad and not okay at all...</span>\n"
		if(2)
			msg += "<span class='boldwarning'>I feel terrible...</span>\n"
		if(3)
			msg += "<span class='boldwarning'>I feel very upset.</span>\n"
		if(4)
			msg += "<span class='boldwarning'>I'm a bit sad.</span>\n"
		if(5)
			msg += "<span class='nicegreen'>I'm alright.</span>\n"
		if(6)
			msg += "<span class='nicegreen'>I feel pretty okay.</span>\n"
		if(7)
			msg += "<span class='nicegreen'>I feel pretty good.</span>\n"
		if(8)
			msg += "<span class='nicegreen'>I feel amazing!</span>\n"
		if(9)
			msg += "<span class='nicegreen'>I love life!</span>\n"

	msg += "<span class='notice'>Moodlets:</span>\n"//All moodlets
	if(mood_events.len)
		for(var/i in mood_events)
			var/datum/mood_event/event = mood_events[i]
			msg += event.description
	else
		msg += "<span class='notice'>I don't have much of a reaction to anything right now.\n</span>"
	to_chat(user, msg)

///Called after moodevent/s have been added/removed.
/datum/component/mood/proc/update_mood()
	mood = 0
	shown_mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		mood += event.mood_change
		if(!event.hidden)
			shown_mood += event.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9
	update_mood_icon()

/datum/component/mood/proc/update_mood_icon()
	if(!screen_obj)
		return

	var/mob/living/owner = parent
	if(!owner.client)
		return

	screen_obj.cut_overlays()
	screen_obj.color = initial(screen_obj.color)

	//lets see if we have any special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for(var/i in mood_events) //adds overlays and sees which special icons need to vie for which one gets the icon_state
		var/datum/mood_event/event = mood_events[i]
		if(!event.special_screen_obj)
			continue

		if(!event.special_screen_replace)
			screen_obj.add_overlay(event.special_screen_obj)
		else
			conflicting_moodies += event
			var/absmood = abs(event.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood

	switch(spirit_level)
		if(1)
			screen_obj.color = "#2eeb9a"
		if(2)
			screen_obj.color = "#86d656"
		if(3)
			screen_obj.color = "#4b96c4"
		if(4)
			screen_obj.color = "#dfa65b"
		if(5)
			screen_obj.color = "#f38943"
		if(6)
			screen_obj.color = "#f15d36"

	if(!conflicting_moodies.len) //no special icons- go to the normal icon states
		screen_obj.icon_state = "mood[mood_level]"
		return

	for(var/i in conflicting_moodies)
		var/datum/mood_event/event = i
		if(abs(event.mood_change) == highest_absolute_mood)
			screen_obj.icon_state = "[event.special_screen_obj]"
			break

///Called on SSmood process
/datum/component/mood/process(delta_time)
	var/mob/living/moody_fellow = parent
	if(moody_fellow.stat == DEAD)
		return //updating spirit during death leads to people getting revived and being completely insane for simply being dead for a long time

	switch(mood_level)
		if(1)
			setSpirit(spirit - 0.3 * delta_time, SPIRIT_BAD)
		if(2)
			setSpirit(spirit - 0.15 * delta_time, SPIRIT_BAD)
		if(3)
			setSpirit(spirit - 0.1 * delta_time, SPIRIT_LOW)
		if(4)
			setSpirit(spirit - 0.05 * delta_time, SPIRIT_POOR)
		if(5)
			setSpirit(spirit, SPIRIT_POOR) //This makes sure that mood gets increased should you be below the minimum.
		if(6)
			setSpirit(spirit + 0.2 * delta_time, SPIRIT_POOR)
		if(7)
			setSpirit(spirit  +0.3 * delta_time, SPIRIT_POOR)
		if(8)
			setSpirit(spirit + 0.4 * delta_time, SPIRIT_NEUTRAL, SPIRIT_MAXIMUM)
		if(9)
			setSpirit(spirit + 0.6*  delta_time, SPIRIT_NEUTRAL, SPIRIT_MAXIMUM)

///Sets spirit to the specified amount and applies effects.
/datum/component/mood/proc/setSpirit(amount, minimum=SPIRIT_BAD, maximum=SPIRIT_HIGH)
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.7
	// If the new amount would move towards the acceptable range faster then use it instead
	if(amount < minimum)
		amount += clamp(minimum - amount, 0, 0.7)
	if(amount > maximum)
		amount = min(spirit, amount)

	if(amount == spirit) //Prevents stuff from flicking around.
		return
	spirit = amount

	var/mob/living/master = parent
	switch(spirit)
		if(SPIRIT_BAD to SPIRIT_LOW)
			master.mood_additive_speed_modifier = 1.0
			master.mood_multiplicative_actionspeed_modifier = 0.25
			spirit_level = 6
		if(SPIRIT_LOW to SPIRIT_POOR)
			master.mood_additive_speed_modifier = 0.5
			master.mood_multiplicative_actionspeed_modifier = 0.25
			spirit_level = 5
		if(SPIRIT_POOR to SPIRIT_DISTURBED)
			master.mood_additive_speed_modifier = 0.25
			master.mood_multiplicative_actionspeed_modifier = 0.25
			spirit_level = 4
		if(SPIRIT_DISTURBED to SPIRIT_NEUTRAL)
			master.mood_additive_speed_modifier = 0.0
			master.mood_multiplicative_actionspeed_modifier = 0.0
			spirit_level = 3
		if(SPIRIT_NEUTRAL + 1 to SPIRIT_HIGH + 1) //shitty hack but +1 to prevent it from responding to super small differences
			master.mood_additive_speed_modifier = 0.0
			master.mood_multiplicative_actionspeed_modifier = -0.1
			spirit_level = 2
		if(SPIRIT_HIGH + 1 to INFINITY)
			master.mood_additive_speed_modifier = 0.0
			master.mood_multiplicative_actionspeed_modifier = -0.1
			spirit_level = 1
	update_mood_icon()

// Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
/datum/component/mood/proc/add_event(datum/source, category, type, ...)
	SIGNAL_HANDLER

	var/datum/mood_event/the_event
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(null, category)
		else
			if(the_event.timeout)
				addtimer(CALLBACK(src, .proc/clear_event, null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)
			return //Don't have to update the event.

	var/list/params = args.Copy(4)
	params.Insert(1, parent)
	the_event = new type(arglist(params))

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, .proc/clear_event, null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/mood/proc/clear_event(datum/source, category)
	SIGNAL_HANDLER

	var/datum/mood_event/event = mood_events[category]
	if(!event)
		return

	mood_events -= category
	qdel(event)
	update_mood()

// Removes all temp moods
/datum/component/mood/proc/remove_temp_moods()
	for(var/i in mood_events)
		var/datum/mood_event/moodlet = mood_events[i]
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
	update_mood()

/datum/component/mood/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	screen_obj.color = "#4b96c4"
	hud.adding += screen_obj

	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!screen_obj)
		return
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	if(hud?.adding)
		hud.adding -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	if(user != parent)
		return
	print_mood(user)

///Called when parent is ahealed.
/datum/component/mood/proc/on_revive(datum/source)
	SIGNAL_HANDLER

	remove_temp_moods()
	setSpirit(initial(spirit))

///Causes direct drain of someone's spirit, call it with a numerical value corresponding how badly you want to hurt their spirit
/datum/component/mood/proc/direct_spirit_drain(datum/source, amount)
	SIGNAL_HANDLER

	setSpirit(spirit + amount)
