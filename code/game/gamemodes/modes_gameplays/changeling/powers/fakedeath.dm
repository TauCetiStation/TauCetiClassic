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
	var/ready2revive = FALSE

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(mob/living/user)
	if(NOCLONE in user.mutations)
		to_chat(user, "<span class='notice'>We could not regenerate. Something wrong with our DNA.</span>")
		user.fake_death = FALSE
		qdel(src) //We dont need that power from now anyway.
		return FALSE

	if(ready2revive)
		user.clear_alert("regen_stasis")
		for(var/mob/M in role.essences)
			M.clear_alert("regen_stasis")

		action.button_icon_state = "fake_death"
		action.button.UpdateIcon()
		if(user.stat != DEAD)
			ready2revive = FALSE
			return
		user.fake_death = 0
		user.stat = CONSCIOUS
		user.reagents.clear_reagents()
		user.rejuvenate()
		ready2revive = FALSE
		to_chat(user, "<span class='notice'>We have regenerated.</span>")
		feedback_add_details("changeling_powers","CR")
		return TRUE

	if(user.stat != DEAD && user.fake_death)
		var/fake_pick = pick(OXY, TOX, CLONE)
		switch(fake_pick)
			if(OXY)
				user.adjustOxyLoss(rand(user.maxHealth * 2.1, user.maxHealth * 3))
			if(TOX)
				user.adjustToxLoss(rand(user.maxHealth * 2.1, user.maxHealth * 3))
			if(CLONE)
				user.adjustCloneLoss(rand(user.maxHealth * 2.1, user.maxHealth * 3))

	role.instatis = TRUE
	user.throw_alert("regen_stasis", /atom/movable/screen/alert/regen_stasis)
	for(var/mob/M in role.essences)
		M.throw_alert("regen_stasis", /atom/movable/screen/alert/regen_stasis)

	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")

	addtimer(CALLBACK(src, PROC_REF(give_revive_ability), user), rand(800, 2000))

	feedback_add_details("changeling_powers","FD")

/obj/effect/proc_holder/changeling/fakedeath/proc/give_revive_ability(mob/living/user)
	if(!role) //Shitspawn case
		to_chat(user, "<span class='notice'>We could not regenerate. Something wrong with us.</span>")
		user.fake_death = FALSE
		qdel(src) //We dont need that power from now anyway.
		return
	role.instatis = FALSE
	user.fake_death = FALSE
	user.clear_alert("regen_stasis")
	for(var/mob/M in role.essences)
		M.clear_alert("regen_stasis")

	if(NOCLONE in user.mutations)
		to_chat(user, "<span class='notice'>We could not regenerate. something wrong with our DNA.</span>")
		qdel(src)
		return
	if(user.stat != DEAD) //Player was resurrected before stasis completion
		to_chat(user, "<span class='notice'>Our stasis was interrupted.</span>")
		ready2revive = FALSE
	else
		to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
		action.button_icon_state = "revive"
		action.button.UpdateIcon()
		ready2revive = TRUE

/obj/effect/proc_holder/changeling/fakedeath/can_sting(mob/user)
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	if(C.instatis) //We already regenerating, no need to start second time in a row.
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
	if(user.stat == DEAD)//In case player gave answer too late
		user.fake_death = FALSE
	else
		user.fake_death = TRUE
	return ..()
