/datum/action/cooldown/spawn_induction_package
	name = "Создать Вступительный Набор"
	check_flags = AB_CHECK_ALIVE
	button_icon_state = "recruit"
	cooldown_time = 300
	/// The family antagonist datum of the "owner" of this action.
	var/datum/faction/gang/my_gang_datum

/datum/action/cooldown/spawn_induction_package/Trigger()
	if(!IsAvailable() || !Checks())
		return FALSE
	if(!my_gang_datum)
		return FALSE
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(H.stat != CONSCIOUS)
		return FALSE

	// we need some stuff to fall back on if we're handlerless
	var/gang_balance_cap = my_gang_datum.gang_balance_cap
	var/lowest_gang_count = my_gang_datum.members.len

	var/list/gangs = find_factions_by_type(/datum/faction/gang)
	for(var/datum/faction/gang/TT in gangs)
		var/alive_gangsters = 0
		for(var/datum/role/gangster/gangers in TT.members)
			if(ishuman(gangers.antag.current) && gangers.antag.current.client && gangers.antag.current.stat == CONSCIOUS)
				alive_gangsters++
		if(!alive_gangsters || TT.members.len <= 1) // Dead or inactive gangs don't count towards the cap.
			continue
		if(TT != my_gang_datum)
			if(alive_gangsters < lowest_gang_count)
				lowest_gang_count = alive_gangsters
	if(my_gang_datum.members.len >= (lowest_gang_count + gang_balance_cap))
		to_chat(H, "Your gang is pretty packed right now. You don't need more members just yet. If the other families expand, you can recruit more members.")
		return FALSE
	to_chat(H, "You pull an induction package from your pockets and place it on the ground.")
	var/obj/item/gang_induction_package/GP = new(get_turf(H))
	GP.name = "\improper [my_gang_datum.name] signup package"
	GP.gang_to_use = my_gang_datum.type
	GP.team_to_use = my_gang_datum
	StartCooldown()
	return TRUE
