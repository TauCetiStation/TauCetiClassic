/datum/hud/proc/add_intents(ui_style = null, act_intent_type = /atom/movable/screen/act_intent)
	action_intent = new act_intent_type
	action_intent.icon = ui_style
	action_intent.update_icon(mymob)
	adding += action_intent

	var/atom/movable/screen/intent
	var/const/list/intent_types = list(
		/atom/movable/screen/intent/help, /atom/movable/screen/intent/push,
		/atom/movable/screen/intent/grab, /atom/movable/screen/intent/harm
		)

	for(var/intent_type in intent_types)
		intent = new intent_type
		intent.update_icon(action_intent)
		intent.screen_loc = act_intent.screen_loc
		adding += intent
