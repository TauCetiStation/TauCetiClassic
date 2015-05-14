/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	req_stat = DEAD

//Revive from regenerative stasis
/obj/effect/proc_holder/changeling/revive/sting_action(var/mob/living/carbon/user)
	user.mind.changeling.purchasedpowers -= src
	if(user.stat == DEAD)
		dead_mob_list -= user
		living_mob_list += user
	if(HUSK in user.mutations)
		user.mutations.Remove(HUSK)
	user.fake_death = 0
	user.stat = CONSCIOUS
	user.tod = null
	user.timeofdeath = 0
	user.reagents.clear_reagents()
/*	user.setToxLoss(0)
	user.setOxyLoss(0)
	user.setCloneLoss(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.radiation = 0
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss()) */
	user.rejuvenate()
	user << "<span class='notice'>We have regenerated.</span>"
	//user.status_flags &= ~(FAKEDEATH)
	//user.update_canmove()
	feedback_add_details("changeling_powers","CR")
	return 1

/obj/effect/proc_holder/changeling/revive/can_sting(var/mob/user)
	if(NOCLONE in user.mutations)
		user << "<span class='notice'>We could not regenerate. Something wrong with our DNA.</span>"
		user.fake_death = 0
		user.mind.changeling.purchasedpowers -= src //We dont need that power from now anyway.
		return
	if(user.stat < 2)//We are alive when using this... Why do we need to keep this ability and even rejuvenate, if revive must used from dead state?
		user << "<span class='notice'>We ready to regenerate, but we need to stop any life activity in our body.</span>"
		return
	return ..()
