/datum/hud/proc/add_intents(ui_style = null, act_intent_type = /atom/movable/screen/act_intent)
	var/atom/movable/screen/using

	action_intent = new act_intent_type
	action_intent.icon = ui_style
	action_intent.update_icon(mymob)

	using = new /atom/movable/screen/intent/help
	using.screen_loc = action_intent.screen_loc
	using.update_icon(ui_style)
	help_intent = using

	using = new /atom/movable/screen/intent/push
	using.screen_loc = action_intent.screen_loc
	using.update_icon(ui_style)
	push_intent = using

	using = new /atom/movable/screen/intent/grab
	using.screen_loc = action_intent.screen_loc
	using.update_icon(ui_style)
	grab_intent = using

	using = new /atom/movable/screen/intent/harm
	using.screen_loc = action_intent.screen_loc
	using.update_icon(ui_style)
	harm_intent = using

	adding += list(action_intent, help_intent, push_intent, grab_intent, harm_intent)
