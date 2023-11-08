/obj/effect/proc_holder/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate."
	helptext = "Can be used before or after death. Duration varies greatly."
	button_icon_state = "fake_death"
	chemical_cost = 20
	genomecost = 0
	req_dna = 1
	req_stat = DEAD
	max_genetic_damage = 100
	can_be_used_in_abom_form = FALSE

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(mob/living/user)

	if(user.fake_death)
		var/fake_pick = pick(OXY, TOX, CLONE)
		switch(fake_pick)
			if(OXY)
				user.adjustOxyLoss(rand(200,300))
			if(TOX)
				user.adjustToxLoss(rand(200,300))
			if(CLONE)
				user.adjustCloneLoss(rand(200,300))

	if(NOCLONE in user.mutations)
		to_chat(user, "<span class='notice'>We could not begin our stasis, something damaged all our DNA.</span>")
		var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
		C.instatis = FALSE
		user.fake_death = FALSE
		return FALSE
	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
	addtimer(CALLBACK(src, PROC_REF(give_revive_ability), user), rand(800, 2000))

	feedback_add_details("changeling_powers","FD")
	return TRUE

/obj/effect/proc_holder/changeling/fakedeath/proc/give_revive_ability(mob/living/user)
	if(!ischangeling(user))
		return
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	if(C?.purchasedpowers)
		C.instatis = FALSE
		user.fake_death = FALSE
		user.clear_alert("regen_stasis")
		for(var/mob/M in C.essences)
			M.clear_alert("regen_stasis")

		if(user.stat != DEAD) //Player was resurrected before stasis completion
			to_chat(user, "<span class='notice'>Our stasis was interrupted.</span>")
			return
		else
			if(NOCLONE in user.mutations)
				to_chat(user, "<span class='notice'>We could not regenerate. something wrong with our DNA.</span>")
			else
				to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
				C.purchasedpowers += new /obj/effect/proc_holder/changeling/revive(null)
				action.button_icon_state = "revive"
				action.button.UpdateIcon()

/obj/effect/proc_holder/changeling/fakedeath/can_sting(mob/user)
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	if(C.instatis) //We already regenerating, no need to start second time in a row.
		return FALSE
	var/obj/effect/proc_holder/changeling/revive/A = locate(/obj/effect/proc_holder/changeling/revive) in C.purchasedpowers
	if(A)
		A.try_to_sting(user)
		return FALSE
	if(user.fake_death)
		return FALSE
	if(user.stat != DEAD)
		if(tgui_alert(usr, "Are we sure we wish to fake our death?",, list("Yes","No")) == "No")
			return FALSE
	if(C.instatis) //In case if user clicked ability several times without making a choice.
		return FALSE
	if(!..())
		return FALSE
	C.instatis = TRUE
	user.throw_alert("regen_stasis", /atom/movable/screen/alert/regen_stasis)
	for(var/mob/M in C.essences)
		M.throw_alert("regen_stasis", /atom/movable/screen/alert/regen_stasis)
	if(user.stat == DEAD)//In case player gave answer too late
		user.fake_death = FALSE
	else
		user.fake_death = TRUE
	return ..()
/*
/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	button_icon_state = "revive"
	req_stat = DEAD

//Revive from regenerative stasis
/obj/effect/proc_holder/changeling/revive/sting_action(mob/living/carbon/user)
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	C.purchasedpowers -= src
	if(user.stat == DEAD)
		dead_mob_list -= user
		alive_mob_list += user
	if(HUSK in user.mutations)
		user.mutations.Remove(HUSK)
	user.fake_death = 0
	user.stat = CONSCIOUS
	user.tod = null
	user.timeofdeath = 0
	user.reagents.clear_reagents()
	user.rejuvenate()
	to_chat(user, "<span class='notice'>We have regenerated.</span>")
	feedback_add_details("changeling_powers","CR")
	return TRUE

/obj/effect/proc_holder/changeling/revive/can_sting(mob/user)
	if(NOCLONE in user.mutations)
		to_chat(user, "<span class='notice'>We could not regenerate. Something wrong with our DNA.</span>")
		user.fake_death = 0
		var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
		C.purchasedpowers -= src //We dont need that power from now anyway.
		return FALSE
	if(user.stat != DEAD)//We are alive when using this... Why do we need to keep this ability and even rejuvenate, if revive must used from dead state?
		var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
		C.purchasedpowers -= src  //If we somehow acquired it, remove upon clicking, to prevent stasis breaking
		to_chat(user, "<span class='notice'>We need to stop any life activity in our body.</span>")
		return FALSE
	return ..()









/obj/effect/proc_holder/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE
	var/revive_ready = FALSE

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(mob/living/user)
	..()
	if(revive_ready)
		INVOKE_ASYNC(src, PROC_REF(revive), user)
		revive_ready = FALSE
		chemical_cost = 15
		to_chat(user, span_notice("We have revived ourselves."))
		build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
	else
		to_chat(user, span_notice("We begin our stasis, preparing energy to arise once more."))
		user.fakedeath(CHANGELING_TRAIT) //play dead
		addtimer(CALLBACK(src, PROC_REF(ready_to_regenerate), user), LING_FAKEDEATH_TIME, TIMER_UNIQUE)
	return TRUE

/obj/effect/proc_holder/changeling/fakedeath/proc/revive(mob/living/carbon/user)
	if(!istype(user))
		return

	user.cure_fakedeath(CHANGELING_TRAIT)
	// Heal all damage and some minor afflictions,
	var/flags_to_heal = (HEAL_DAMAGE|HEAL_BODY|HEAL_STATUS|HEAL_CC_STATUS)
	// but leave out limbs so we can do it specially
	user.revive(flags_to_heal & ~HEAL_LIMBS)

	var/static/list/dont_regenerate = list(BODY_ZONE_HEAD) // headless changelings are funny
	if(!length(user.get_missing_limbs() - dont_regenerate))
		return

	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	user.visible_message(
		span_warning("[user]'s missing limbs reform, making a loud, grotesque sound!"),
		span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
		span_hear("You hear organic matter ripping and tearing!"),
	)
	user.emote("scream")
	// Manually call this (outside of revive/fullheal) so we can pass our blacklist
	user.regenerate_limbs(dont_regenerate)

/obj/effect/proc_holder/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(!user?.mind)
		return

	var/datum/antagonist/changeling/ling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!ling || !(src in ling.innate_powers))
		return

	to_chat(user, span_notice("We are ready to revive."))
	chemical_cost = 0
	revive_ready = TRUE
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

/obj/effect/proc_holder/changeling/fakedeath/can_sting(mob/living/user)
	if(revive_ready)
		return ..()

	if(!can_enter_stasis(user))
		return
	//Confirmation for living changelings if they want to fake their death
	if(user.stat != DEAD)
		if(tgui_alert(user, "Are we sure we wish to fake our own death?", "Feign Death", list("Yes", "No")) != "Yes")
			return
		if(QDELETED(user) || QDELETED(src) || !can_enter_stasis(user))
			return

	return ..()

/obj/effect/proc_holder/changeling/fakedeath/proc/can_enter_stasis(mob/living/user)
	if(HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		user.balloon_alert(user, "already reviving!")
		return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/fakedeath/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if(revive_ready)
		name = "Revive"
		desc = "We arise once more."
	else
		name = "Reviving Stasis"
		desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
	return ..()

/obj/effect/proc_holder/changeling/fakedeath/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = revive_ready ? "revive" : "fake_death"
	return ..()
*/
