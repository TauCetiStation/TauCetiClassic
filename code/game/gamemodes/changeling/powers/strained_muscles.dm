/obj/effect/proc_holder/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster."
	helptext = "The strain will make us tired, and we will rapidly become fatigued. Standard weight restrictions, like hardsuits, still apply. Cannot be used in lesser form."
	genomecost = 3
	req_human = 1
	max_genetic_damage = 5
	var/stacks = 0 //Increments every second; damage increases over time
	var/active = 0
	var/mob/living/carbon/human/owner

/obj/effect/proc_holder/changeling/strained_muscles/sting_action(mob/living/carbon/user)

	if(stacks && !active)
		to_chat(user,"<span class='danger'>We are still exhausted.</span>")
		return
	owner = user
	var/datum/changeling/changeling = user.mind.changeling
	active = !active
	if(active)
		if(changeling.chem_charges < 10) // we doesn't use req_chem variable cuz we always switch this ability
			to_chat(user, "<span class='warning'>We require at least 10 units of chemicals to do that!</span>")
			active = !active
		else
			changeling.chem_charges -= 10
			changeling.strained_muscles = 1
			to_chat(user,"<span class='notice'>Our muscles tense and strengthen.</span>")
			START_PROCESSING(SSobj, src)
	else
		to_chat(user,"<span class='notice'>Our muscles relax.</span>")
		changeling.strained_muscles = 0

	feedback_add_details("changeling_powers","SANIC")
	return 1

/obj/effect/proc_holder/changeling/strained_muscles/process()
	if(active)
		stacks++
		if(stacks >= 30)
			to_chat(owner,"<span class='danger'>We collapse in exhaustion.</span>")
			owner.Weaken(3)
			owner.emote("gasp")
			owner.mind.changeling.strained_muscles = 0
			active = !active

		if(owner.stat != CONSCIOUS || owner.halloss >= 90)
			active = !active
			to_chat(owner,"<span class='notice'>Our muscles relax without the energy to strengthen them.</span>")
			owner.Weaken(2)
			owner.mind.changeling.strained_muscles = 0
		if(stacks == 10)
			to_chat(owner,"<span class='warning'>Our legs are really starting to hurt...</span>")
		if(stacks > 10)
			owner.apply_effect(5,AGONY)
	else if(stacks)
		stacks -= 0.25
	else
		STOP_PROCESSING(SSobj, src)