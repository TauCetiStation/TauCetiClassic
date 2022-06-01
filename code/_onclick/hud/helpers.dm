/datum/hud/proc/init_screen(screen_type)
	var/atom/movable/screen/screen = new screen_type
	screen.add_to_hud(src)

/datum/hud/proc/init_screens(list/types)
	for(var/screen_type in types)
		init_screen(screen_type)

/datum/hud/proc/add_hands(r_type = /atom/movable/screen/inventory/hand/r, l_type = /atom/movable/screen/inventory/hand/l)
	if(r_type)
		mymob.r_hand_hud_object = new r_type
		mymob.r_hand_hud_object.add_to_hud(src)

	if(l_type)
		mymob.l_hand_hud_object = new l_type
		mymob.l_hand_hud_object.add_to_hud(src)

/datum/hud/proc/add_roles()
	var/list/antag_roles = mymob.mind.antag_roles

	for(var/id in antag_roles)
		var/datum/role/role = antag_roles[id]
		role.add_ui(src)
