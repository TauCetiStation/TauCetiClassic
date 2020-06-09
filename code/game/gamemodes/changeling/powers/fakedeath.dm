/obj/effect/proc_holder/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate."
	helptext = "Can be used before or after death. Duration varies greatly."
	chemical_cost = 20
	genomecost = 0
	req_dna = 1
	req_stat = DEAD
	max_genetic_damage = 100

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(mob/living/user)

	if(user.fake_death)
		var/fake_pick = pick("oxy", "tox", "clone")
		switch(fake_pick)
			if("oxy")
				user.adjustOxyLoss(rand(200,300))
			if("tox")
				user.adjustToxLoss(rand(200,300))
			if("clone")
				user.adjustCloneLoss(rand(200,300))

		//user.death(0)
		//dead_mob_list -= user
		//alive_mob_list += user
		//user.status_flags |= FAKEDEATH		//play dead
		//user.fake_death = 1
		//user.update_canmove()

		//if(user.stat != DEAD)
		//	user.emote("deathgasp")
		//	user.tod = worldtime2text()

	if(NOCLONE in user.mutations)
		to_chat(user, "<span class='notice'>We could not begin our stasis, something damaged all our DNA.</span>")
		user.mind.changeling.instatis = FALSE
		user.fake_death = FALSE
		return
	else
		to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
		addtimer(CALLBACK(src, .proc/give_revive_ability, user), rand(800, 2000))

	feedback_add_details("changeling_powers","FD")
	return TRUE

/obj/effect/proc_holder/changeling/fakedeath/proc/give_revive_ability(mob/living/user)
	if(user && user.mind && user.mind.changeling && user.mind.changeling.purchasedpowers)
		user.mind.changeling.instatis = FALSE
		user.fake_death = FALSE
		user.clear_alert("regen_stasis")
		for(var/mob/M in user.mind.changeling.essences)
			M.clear_alert("regen_stasis")

		if(user.stat != DEAD) //Player was resurrected before stasis completion
			to_chat(user, "<span class='notice'>Our stasis was interrupted.</span>")
			return
		else
			if(NOCLONE in user.mutations)
				to_chat(user, "<span class='notice'>We could not regenerate. something wrong with our DNA.</span>")
			else
				to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
				user.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/revive(null)

/obj/effect/proc_holder/changeling/fakedeath/can_sting(mob/user)
	if(user.mind.changeling.instatis) //We already regenerating, no need to start second time in a row.
		return
	if(locate(/obj/effect/proc_holder/changeling/revive) in user.mind.changeling.purchasedpowers)
		to_chat(user, "<span class='notice'>We already prepared our ability.</span>")
		return
	if(user.fake_death)
		return
	if(user.stat != DEAD)
		if(alert("Are we sure we wish to fake our death?",null,"Yes","No") == "No")
			return
	if(user.mind.changeling.instatis) //In case if user clicked ability several times without making a choice.
		return
	user.mind.changeling.instatis = TRUE
	user.throw_alert("regen_stasis", /obj/screen/alert/regen_stasis)
	for(var/mob/M in user.mind.changeling.essences)
		M.throw_alert("regen_stasis", /obj/screen/alert/regen_stasis)
	if(user.stat == DEAD)//In case player gave answer too late
		user.fake_death = FALSE
	else
		user.fake_death = TRUE
	return ..()
