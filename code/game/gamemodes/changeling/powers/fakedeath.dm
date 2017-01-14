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
		var/fake_pick = pick("oxy", "tox", "fire", "clone")
		switch(fake_pick)
			if("oxy")
				user.adjustOxyLoss(rand(200,300))
			if("tox")
				user.adjustToxLoss(rand(200,300))
			if("fire")
				user.adjustFireLoss(rand(200,300))
			if("clone")
				user.adjustCloneLoss(rand(200,300))

		//user.death(0)
		//dead_mob_list -= user
		//living_mob_list += user
		//user.status_flags |= FAKEDEATH		//play dead
		//user.fake_death = 1
		//user.update_canmove()

		//if(user.stat != DEAD)
		//	user.emote("deathgasp")
		//	user.tod = worldtime2text()

	if(NOCLONE in user.mutations)
		to_chat(user, "<span class='notice'>We could not begin our stasis, something damaged all our DNA.</span>")
		user.mind.changeling.instatis = 0
		user.fake_death = 0
		return
	else
		to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")

	spawn(rand(800,2000))
		if(user && user.mind && user.mind.changeling && user.mind.changeling.purchasedpowers)
			user.mind.changeling.instatis = 0
			user.fake_death = 0
			if(user.stat != DEAD) //Player was resurrected before stasis completion
				to_chat(user, "<span class='notice'>Our stasis was interrupted.</span>")
				return
			else
				if(NOCLONE in user.mutations)
					to_chat(user, "<span class='notice'>We could not regenerate. something wrong with our DNA.</span>")
				else
					to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
					user.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/revive(null)

	feedback_add_details("changeling_powers","FD")
	return 1

/obj/effect/proc_holder/changeling/fakedeath/can_sting(mob/user)
	//if(user.status_flags & FAKEDEATH)
	if(user.mind.changeling.instatis) //We already regenerating, no need to start second time in a row.
		return

	for(var/obj/effect/proc_holder/changeling/revive/ability_to_check in user.mind.changeling.purchasedpowers)
		if(istype(ability_to_check, /obj/effect/proc_holder/changeling/revive))
			to_chat(user, "<span class='notice'>We already prepared our ability.</span>")
			return

	if(user.fake_death == 1)
		return
	//if(!user.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changeling if they want to fake their death
	//	return
	if(user.stat != DEAD)
		switch(alert("Are we sure we wish to fake our death?",null,"Yes","No"))
			if("No")
				return
			if("Yes")
				if(user.mind.changeling.instatis) //In case if user clicked ability several times without making a choice.
					return
				else
					user.mind.changeling.instatis = 1
					if(user.stat == DEAD)//In case player gave answer too late
						user.fake_death = 0
					else
						user.fake_death = 1
	return ..()
