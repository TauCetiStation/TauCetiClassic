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

/datum/hud/proc/get_screen(screen_type, icon = null, color = null, alpha = null)
	var/atom/movable/screen/screen = new screen_type
	if(icon)
		screen.icon = icon
	if(color)
		screen.color = color
	if(alpha)
		screen.alpha = alpha
	return screen

/datum/hud/proc/init_screens(list/types, icon = null, color = null, alpha = null, list/list_to)
	if(!list_to)
		list_to = list()

	for(var/screen_type in types)
		list_to += get_screen(screen_type, icon, color, alpha)

	return list_to

/datum/hud/proc/add_move_intent(icon = null, color = null, alpha = null, type = /atom/movable/screen/move_intent)
	move_intent = get_screen(type, icon, color, alpha)
	move_intent.update_icon(mymob)
	adding += move_intent

/datum/hud/proc/add_hands(icon = null, color = null, alpha = null, r_type = /atom/movable/screen/inventory/hand/r, l_type = /atom/movable/screen/inventory/hand/l)
	if(r_type)
		r_hand_hud_object = get_screen(r_type, icon, color, alpha)
		r_hand_hud_object.update_icon(mymob)
		adding += r_hand_hud_object

	if(l_type)
		l_hand_hud_object = get_screen(l_type, icon, color, alpha)
		l_hand_hud_object.update_icon(mymob)
		adding += l_hand_hud_object

/datum/hud/proc/add_throw_icon(icon = null, color = null, alpha = null, type = /atom/movable/screen/throw)
	mymob.throw_icon = get_screen(type, icon, color, alpha)
	hotkeybuttons += mymob.throw_icon

/datum/hud/proc/add_internals(icon = null, type = /atom/movable/screen/internal)
	var/atom/movable/screen/internals = get_screen(type, icon)
	mymob.internals = internals
	internals.update_icon(mymob)
	mymob.client.screen += internals

/datum/hud/proc/add_healths(icon = null, type = /atom/movable/screen/health)
	mymob.healths = new type
	mymob.client.screen += mymob.healths

/datum/hud/proc/add_health_doll(type = /atom/movable/screen/health_doll)
	mymob.healthdoll = new type
	mymob.client.screen += mymob.healthdoll

/datum/hud/proc/add_nutrition_icon(type = /atom/movable/screen/nutrition)
	mymob.nutrition_icon = new  type
	mymob.nutrition_icon.update_icon(mymob)
	mymob.client.screen += mymob.nutrition_icon

/datum/hud/proc/add_pullin(icon = null, type = /atom/movable/screen/pull)
	mymob.pullin = get_screen(type, icon)
	mymob.pullin.update_icon(mymob)
	hotkeybuttons += mymob.pullin

/datum/hud/proc/add_zone_sel(icon = null, color = null, alpha = null, type = /atom/movable/screen/zone_sel)
	mymob.zone_sel = get_screen(type, icon)
	mymob.zone_sel.update_icon()
	mymob.client.screen += mymob.zone_sel

/datum/hud/proc/add_gun_setting(type = /atom/movable/screen/gun/mode)
	mymob.gun_setting_icon = new type
	mymob.gun_setting_icon.update_icon(mymob.client)

	if(mymob.client.gun_mode)
		mymob.client.add_gun_icons()

	mymob.client.screen += mymob.gun_setting_icon

/datum/hud/proc/add_changeling()
	lingchemdisplay = new /atom/movable/screen/chemical_display
	mymob.client.screen += lingchemdisplay

	if(iscarbon(mymob))
		lingstingdisplay = new /atom/movable/screen/current_sting
		mymob.client.screen += lingstingdisplay

/datum/hud/proc/add_wanted_level()
	wanted_lvl = new /atom/movable/screen/wanted
	adding += wanted_lvl
