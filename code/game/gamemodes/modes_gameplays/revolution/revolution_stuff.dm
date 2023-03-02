/obj/item/device/flash/rev_flash
	var/headrev_only = TRUE
	var/mob/living/carbon/human/convert_target = null

/obj/item/device/flash/rev_flash/AdjustFlashEffect(mob/living/M)
	M.AdjustWeakened(4)
	M.flash_eyes()

/obj/item/device/flash/rev_flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The [name] is broken</span>")
		return
	flash_recharge()
	if(flash_convert(user))
		//red color flash for attract attention
		flash_lighting_fx(_color = LIGHT_COLOR_FIREPLACE)
		//give them time to think about the situation
		convert_target.Paralyse(4)
	else
		playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	flick("flash2", src)
	playsound(src, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)

/obj/item/device/flash/rev_flash/proc/flash_convert(mob/living/carbon/user)
	var/datum/role/user_role = null
	//if we don't need converting by other revolutionaries/antags
	if(headrev_only)
		if(isrole(HEADREV, user))
			user_role = user.mind.GetRole(HEADREV)
	//find user's roles, early return if have nothing
	else
		for(var/role in user.mind.antag_roles)
			var/datum/role/R = user.mind.GetRole(role)
			if(R)
				user_role = R
				break
	if(!user_role)
		to_chat(user, "<span class='warning'>*click* *click*</span>")
		return FALSE
	//select target [convert_target] for convert
	var/list/victim_list = list()
	for(var/mob/living/carbon/human/H in view(1, user))
		if(H == user)
			continue
		var/image/I = image(H.icon, H.icon_state)
		I.appearance = H
		victim_list[H] = I
	convert_target = show_radial_menu(user, src, victim_list, tooltips = TRUE)
	if(!convert_target)
		to_chat(user, "<span class='warning'>*click* *click*</span>")
		return FALSE
	//check target implants, mind
	if(convert_target.ismindshielded())
		to_chat(user, "<span class='warning'>[convert_target] mind seems to be protected!</span>")
		return FALSE
	if(convert_target.isloyal())
		to_chat(user, "<span class='warning'>[convert_target] mind is already washed by Nanotrasen!</span>")
		return FALSE
	if(!convert_target.client || !convert_target.mind)
		to_chat(user, "<span class='warning'>The target must be conscious and have mind!</span>")
		return FALSE
	//if you break the distance, there should be no effect
	if(get_dist(user, convert_target) > 1)
		to_chat(user, "<span class='warning'>You need to be closer to [convert_target]!</span>")
		return FALSE
	/*	Concept requires: target must be incapacitating.
		There is no meta on revolution and that device.
		Dont need lol-convert						*/
	var/have_incapacitating = FALSE
	for(var/effect in convert_target.status_effects)
		var/datum/status_effect/incapacitating/S = effect
		if(S)
			have_incapacitating = TRUE
	if(!have_incapacitating)
		to_chat(user, "<span class='warning'>Make [convert_target] helpless against you!</span>")
		return FALSE
	if(convert_target.eyecheck() > 0)
		user.visible_message("<span class='warning'>[user] fails to blind [convert_target] with the flash!</span>",
							"<span class='warning'>You fails to blind [convert_target] with the [src].</span>")
		return FALSE
	//find all user's factions and add target as recruit
	var/list/factions = find_factions_by_member(user_role, user.mind)
	for(var/datum/faction/faction in factions)
		//No double convert
		if(faction.get_member_by_mind(convert_target.mind))
			continue
		add_faction_member(faction, convert_target)
	return TRUE

/obj/item/device/flash/rev_flash/emp_act(severity)
	return
