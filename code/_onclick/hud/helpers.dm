/datum/hud/proc/add_intents(ui_style = null, act_intent_type = /atom/movable/screen/act_intent)
	action_intent = new act_intent_type
	action_intent.icon = ui_style
	action_intent.update_icon(mymob)
	adding += action_intent

	var/atom/movable/screen/intent
	var/list/intent_types = list(
		/atom/movable/screen/intent/help, /atom/movable/screen/intent/push,
		/atom/movable/screen/intent/grab, /atom/movable/screen/intent/harm
		)

	for(var/intent_type in intent_types)
		intent = new intent_type
		intent.update_icon(action_intent)
		intent.screen_loc = action_intent.screen_loc
		adding += intent

/datum/hud/proc/init_screens(list/types, icon = null, color = null, alpha = null, list/list_to)
	if(!list_to)
		list_to = list()

	var/atom/movable/screen/screen
	for(var/screen_type in types)
		screen = new screen_type
		if(icon)
			screen.icon = icon
		if(color)
			screen.color = color
		if(alpha)
			screen.alpha = alpha
		list_to += screen

	return list_to
