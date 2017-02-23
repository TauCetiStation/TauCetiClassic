/obj/effect/proc_holder/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off."
	genomecost = 2
	chemical_cost = 0
	req_human = 1
	max_genetic_damage = 50
	var/active = 0
	var/mob/living/carbon/human/owner

/obj/effect/proc_holder/changeling/chameleon_skin/sting_action(mob/living/carbon/user)
	if(!ishuman(user))
		return
	owner = user
	if(active)
		to_chat(user, "<span class='notice'>We feel oddly exposed.</span>")
		owner.mind.changeling.chem_recharge_slowdown -= 0.25
		SSobj.processing.Remove(src)
		owner.alpha = 255
	else
		to_chat(user, "<span class='notice'>We feel one with our surroundings.</span>")
		owner.alpha = 200
		owner.mind.changeling.chem_recharge_slowdown += 0.25
		SSobj.processing |= src
	active = !active
	feedback_add_details("changeling_powers","CS")
	return 1

/obj/effect/proc_holder/changeling/chameleon_skin/process()
	owner.alpha = max(0, owner.alpha - 25)
	if(owner.l_hand)
		var/obj/item/I = owner.l_hand
		if(!(I.flags & ABSTRACT))
			owner.alpha = 200
	if(owner.r_hand)
		var/obj/item/I = owner.r_hand
		if(!(I.flags & ABSTRACT))
			owner.alpha = 200
	if(owner.l_move_time + 40 > world.time) // looks like a shit, but meh
		owner.alpha = 200
	if(owner.stat == DEAD || owner.lying || owner.buckled)
		SSobj.processing.Remove(src)
		active = !active
		owner.alpha = 255


