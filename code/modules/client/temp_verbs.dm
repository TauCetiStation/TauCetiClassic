// Allow temporary custom verbs for events/maps/etc.
var/global/list/temp_player_verbs = list()
var/global/list/temp_admin_verbs = list()

/proc/setup_temp_player_verbs(add_verbs, source)
	if(!add_verbs)
		return

	message_admins("Additional player verbs added[source && ", source: [source]"]!")
	log_debug("Additional player verbs added[source && ", source: [source]"].")

	global.temp_player_verbs |= add_verbs

	for(var/client/C in global.clients)
		C.verbs |= add_verbs

/proc/clean_temp_player_verbs()
	if(!length(global.temp_player_verbs))
		return

	for(var/client/C in global.clients)
		C.verbs -= global.temp_player_verbs

	global.temp_player_verbs = null

/proc/setup_temp_admin_verbs(add_verbs, source)
	if(!add_verbs)
		return

	message_admins("Additional admin verbs added[source && ", source: [source]"]!")
	log_debug("Additional admin verbs added[source && ", source: [source]"].")

	global.temp_admin_verbs |= add_verbs

	global.admin_verbs_admin |= add_verbs // adds verbs for +ADMIN, but verb can be with any permissions check

	load_admins() // too heavy and reloads deadmined admins, need better way to update verbs

/proc/clean_temp_admin_verbs()
	if(!length(global.temp_admin_verbs))
		return

	global.admin_verbs_admin -= global.temp_admin_verbs
	global.temp_admin_verbs = null

	load_admins()
