/proc/get_all_antag_huds()
	RETURN_TYPE(/list)
	var/static/list/all_antag_huds

	if(!all_antag_huds)
		all_antag_huds = list()
		for(var/hud_name in global.huds)
			if(!istype(global.huds[hud_name], /datum/atom_hud/antag))
				continue
			all_antag_huds += global.huds[hud_name]

	return all_antag_huds

/datum/atom_hud/antag
	hud_icons = list(ANTAG_HUD)
	var/self_visible = TRUE
	var/icon_color //will set the icon color to this
	var/background_state

/datum/atom_hud/antag/team
	hud_icons = list(ANTAG_HUD)

/datum/atom_hud/antag/hidden
	self_visible = FALSE

/datum/atom_hud/antag/bg_red
	background_state = "hud_team_bg_red"

/datum/atom_hud/antag/bg_blue
	background_state = "hud_team_bg_blue"

/datum/atom_hud/antag/proc/join_hud(mob/M)
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	if(M.mind.antag_hud) //note: please let this runtime if a mob has no mind, as mindless mobs shouldn't be getting antagged
		M.mind.antag_hud.leave_hud(M)

	if(ANTAG_HUD in M.hud_possible) //Current mob does not support antag huds ie newplayer
		add_to_hud(M)
		if(self_visible)
			add_hud_to(M)

	M.mind.antag_hud = src

/datum/atom_hud/antag/proc/leave_hud(mob/M)
	if(!M)
		return
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	if(M.mind)
		M.mind.antag_hud = null

//GAME_MODE PROCS
//called to set a mob's antag icon state
/proc/set_antag_hud(mob/M, new_icon_state, hudindex)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	var/datum/atom_hud/antag/specific_hud = hudindex ? global.huds[hudindex] : null
	if(holder)
		holder.icon_state = new_icon_state
		if(specific_hud)
			if(specific_hud.icon_color)
				holder.color = specific_hud.icon_color
			if(specific_hud.background_state) // idk if it's ok and maybe should be two different huds but i don't understant huds
				var/image/underlay = image('icons/hud/hud.dmi', specific_hud.background_state)
				holder.underlays += underlay

	if(M.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're antagging a mindless mob, meaning we should runtime
		M.mind.antag_hud_icon_state = new_icon_state
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		holder.pixel_y = H.species.hud_offset_y
		holder.pixel_x = H.species.hud_offset_x

//MIND PROCS
//these are called by mind.transfer_to()
/datum/mind/proc/transfer_antag_huds(datum/atom_hud/antag/newhud)
	leave_all_antag_huds()
	set_antag_hud(current, antag_hud_icon_state)
	if(newhud)
		newhud.join_hud(current)

/datum/mind/proc/leave_all_antag_huds()
	for(var/hud in get_all_antag_huds())
		var/datum/atom_hud/antag/H = hud
		if(H.hudatoms[current])
			H.leave_hud(current)
