/datum/hud/proc/init_screen(screen_type)
	var/atom/movable/screen/screen = new screen_type
	screen.add_to_hud(src)

/datum/hud/proc/init_screens(list/types)
	for(var/screen_type in types)
		init_screen(screen_type)

/datum/hud/proc/add_roles()
	var/list/antag_roles = mymob.mind.antag_roles

	for(var/id in antag_roles)
		var/datum/role/role = antag_roles[id]
		role.add_ui(src)
