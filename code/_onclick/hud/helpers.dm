/datum/hud/proc/add_intents(act_intent_type = /atom/movable/screen/complex/act_intent)
	mymob.action_intent = new act_intent_type
	mymob.action_intent.add_to_hud(src)

/datum/hud/proc/init_screen(screen_type)
	var/atom/movable/screen/screen = new screen_type
	screen.add_to_hud(src)

/datum/hud/proc/init_screens(list/types)
	for(var/screen_type in types)
		init_screen(screen_type)

/datum/hud/proc/add_move_intent(type = /atom/movable/screen/move_intent)
	mymob.move_intent = new type
	mymob.move_intent.add_to_hud(src)

/datum/hud/proc/add_hands(r_type = /atom/movable/screen/inventory/hand/r, l_type = /atom/movable/screen/inventory/hand/l)
	if(r_type)
		mymob.r_hand_hud_object = new r_type
		mymob.r_hand_hud_object.add_to_hud(src)

	if(l_type)
		mymob.l_hand_hud_object = new l_type
		mymob.l_hand_hud_object.add_to_hud(src)

/datum/hud/proc/add_throw_icon(type = /atom/movable/screen/throw)
	mymob.throw_icon = new type
	mymob.throw_icon.add_to_hud(src)

/datum/hud/proc/add_internals(type = /atom/movable/screen/internal)
	mymob.internals = new type
	mymob.internals.add_to_hud(src)

/datum/hud/proc/add_healths(type = /atom/movable/screen/health)
	mymob.healths = new type
	mymob.healths.add_to_hud(src)

/datum/hud/proc/add_health_doll(type = /atom/movable/screen/health_doll)
	mymob.healthdoll = new type
	mymob.healthdoll.add_to_hud(src)

/datum/hud/proc/add_nutrition_icon(type = /atom/movable/screen/nutrition)
	mymob.nutrition_icon = new  type
	mymob.nutrition_icon.add_to_hud(src)

/datum/hud/proc/add_pullin(type = /atom/movable/screen/pull)
	mymob.pullin = new type
	mymob.pullin.add_to_hud(src)

/datum/hud/proc/add_zone_sel(type = /atom/movable/screen/zone_sel)
	mymob.zone_sel = new type
	mymob.zone_sel.add_to_hud(src)

/datum/hud/proc/add_gun_setting(type = /atom/movable/screen/complex/gun)
	mymob.gun_setting_icon = new type
	mymob.gun_setting_icon.add_to_hud(src)

/datum/hud/proc/add_roles()
	var/list/antag_roles = mymob.mind.antag_roles

	for(var/id in antag_roles)
		var/datum/role/role = antag_roles[id]
		role.add_ui(src)
