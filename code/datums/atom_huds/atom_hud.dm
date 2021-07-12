/* HUD DATUMS */

var/global/list/all_huds = list()

//global HUD LIST
//if you add new defines, then change number of assoc list
var/global/list/huds[23]

/proc/init_hud_list() // proc used in global_list.dm
	// Crooked port from TG, but he needed
	// atom_hud.dm defines
	huds[DATA_HUD_SECURITY] = new/datum/atom_hud/data/security
	huds[DATA_HUD_MEDICAL] = new/datum/atom_hud/data/medical
	huds[DATA_HUD_MEDICAL_ADV] = new/datum/atom_hud/data/medical/adv
	huds[DATA_HUD_DIAGNOSTIC] = new/datum/atom_hud/data/diagnostic
	huds[DATA_HUD_HOLY] = new/datum/atom_hud/holy
	huds[DATA_HUD_BROKEN] = new/datum/atom_hud/data/broken
	huds[DATA_HUD_MINER] = new/datum/atom_hud/mine
	huds[DATA_HUD_GOLEM] = new/datum/atom_hud/golem
	huds[DATA_HUD_EMBRYO] = new/datum/atom_hud/embryo
	huds[ANTAG_HUD_CULT] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_REV] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_OPS] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_WIZ] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_SHADOW] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_TRAITOR] = new/datum/atom_hud/antag/hidden
	huds[ANTAG_HUD_NINJA] = new/datum/atom_hud/antag/hidden
	huds[ANTAG_HUD_CHANGELING] = new/datum/atom_hud/antag/hidden
	huds[ANTAG_HUD_ABDUCTOR] = new/datum/atom_hud/antag/hidden
	huds[ANTAG_HUD_ALIEN] = new/datum/atom_hud/antag/hidden
	huds[ANTAG_HUD_DEATHCOM] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_ERT] = new/datum/atom_hud/antag
	huds[ANTAG_HUD_MALF] = new/datum/atom_hud/antag/hidden
	huds[ANTAG_HUD_ZOMB] = new/datum/atom_hud/antag

/datum/atom_hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list

	var/list/next_time_allowed = list() //mobs associated with the next time this hud can be added to them
	var/list/queued_to_see = list() //mobs that have triggered the cooldown and are queued to see the hud, but do not yet
	var/list/hud_exceptions = list() // huduser = list(ofatomswiththeirhudhidden) - aka everyone hates targeted invisiblity

/datum/atom_hud/New()
	global.all_huds += src

/datum/atom_hud/Destroy()
	for(var/v in hudusers)
		remove_hud_from(v)
	for(var/v in hudatoms)
		remove_from_hud(v)
	global.all_huds -= src
	return ..()

/datum/atom_hud/proc/remove_hud_from(mob/M, absolute = FALSE)
	if(!M || !hudusers[M])
		return
	if (absolute || !--hudusers[M])
		UnregisterSignal(M, COMSIG_PARENT_QDELETING)
		hudusers -= M
		if(next_time_allowed[M])
			next_time_allowed -= M
		if(queued_to_see[M])
			queued_to_see -= M
		else
			for(var/atom/A in hudatoms)
				remove_from_single_hud(M, A)

/datum/atom_hud/proc/remove_from_hud(atom/A)
	if(!A)
		return FALSE
	for(var/mob/M in hudusers)
		remove_from_single_hud(M, A)
	hudatoms -= A
	return TRUE

/datum/atom_hud/proc/remove_from_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A || !A.hud_list)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]

/datum/atom_hud/proc/add_hud_to(mob/M)
	if(!M)
		return
	if(!hudusers[M])
		hudusers[M] = 1
		RegisterSignal(M, COMSIG_PARENT_QDELETING, .proc/unregister_mob)
		if(next_time_allowed[M] > world.time)
			if(!queued_to_see[M])
				addtimer(CALLBACK(src, .proc/show_hud_images_after_cooldown, M), next_time_allowed[M] - world.time)
				queued_to_see[M] = TRUE
		else
			next_time_allowed[M] = world.time + ADD_HUD_TO_COOLDOWN
			for(var/atom/A in hudatoms)
				add_to_single_hud(M, A)
	else
		hudusers[M]++

/datum/atom_hud/proc/unregister_mob(datum/source, force)
	SIGNAL_HANDLER
	remove_hud_from(source, TRUE)

/datum/atom_hud/proc/hide_single_atomhud_from(hud_user, hidden_atom)
	if(hudusers[hud_user])
		remove_from_single_hud(hud_user,hidden_atom)
	if(!hud_exceptions[hud_user])
		hud_exceptions[hud_user] = list(hidden_atom)
	else
		hud_exceptions[hud_user] += hidden_atom

/datum/atom_hud/proc/unhide_single_atomhud_from(hud_user, hidden_atom)
	hud_exceptions[hud_user] -= hidden_atom
	if(hudusers[hud_user])
		add_to_single_hud(hud_user,hidden_atom)

/datum/atom_hud/proc/show_hud_images_after_cooldown(M)
	if(queued_to_see[M])
		queued_to_see -= M
		next_time_allowed[M] = world.time + ADD_HUD_TO_COOLDOWN
		for(var/atom/A in hudatoms)
			add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_hud(atom/A)
	if(!A)
		return FALSE
	hudatoms |= A
	for(var/mob/M in hudusers)
		if(!queued_to_see[M])
			add_to_single_hud(M, A)
	return TRUE

/datum/atom_hud/proc/add_to_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A || !A.hud_list)
		return
	for(var/i in hud_icons)
		if(A.hud_list[i] && (!hud_exceptions[M] || !(A in hud_exceptions[M])))
			M.client.images |= A.hud_list[i]

//MOB PROCS
/mob/proc/reload_huds()
	for(var/datum/atom_hud/hud in global.all_huds)
		if(hud && hud.hudusers[src])
			for(var/atom/A in hud.hudatoms)
				hud.add_to_single_hud(src, A)

/mob/dead/new_player/reload_huds()
	return

/mob/proc/add_click_catcher()
	client.screen += client.void

/mob/dead/new_player/add_click_catcher()
	return
