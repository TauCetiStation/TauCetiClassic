/obj/effect/proc_holder/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim."
	chemical_cost = 0
	genomecost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/absorbDNA/can_sting(var/mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		user << "<span class='warning'>We are already absorbing!</span>"
		return

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		user << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>"
		return
	if(G.state <= GRAB_NECK)
		user << "<span class='warning'>We must have a tighter grip to absorb this creature.</span>"
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/absorbDNA/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user << "<span class='notice'>We extend a proboscis.</span>"
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
			if(3)
				user << "<span class='notice'>We stab [target] with the proboscis.</span>"
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>")
				target << "<span class='danger'>You feel a sharp stabbing pain!</span>"
				var/datum/organ/external/affecting = target.get_organ(user.zone_sel.selecting)
				if(affecting.take_damage(39,0,1,0,"large organic needle"))
					target:UpdateDamageIcon()
					continue

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			user << "<span class='warning'>Our absorption of [target] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	user << "<span class='notice'>We have absorbed [target]!</span>"
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	target << "<span class='danger'>You have been absorbed by the changeling!</span>"

	changeling.absorb_dna(target)

	if(user.nutrition < 400) user.nutrition = min((user.nutrition + target.nutrition), 400)
	//Steal all of their languages!
	for(var/language in target.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	user.changeling_update_languages(changeling.absorbed_languages)

	//Steal their species!
	if(target.species && !(target.species.name in changeling.absorbed_species))
		changeling.absorbed_species += target.species.name

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(src, 0) //I can read your mind, kekeke. Output all their notes.

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += target.mind.changeling.absorbedcount
			if(target.mind.changeling.absorbed_dna)
				for(var/dna_data in target.mind.changeling.absorbed_dna)	//steal all their loot
					if(dna_data in changeling.absorbed_dna)
						continue
					changeling.absorbed_dna += dna_data
				target.mind.changeling.absorbed_dna.len = 1

			changeling.geneticpoints += target.mind.changeling.geneticpoints
			target.mind.changeling.absorbedcount = 0
	else
		changeling.chem_charges += 10

	changeling.isabsorbing = 0
	changeling.geneticpoints +=2
	target.death(0)
	target.Drain()
	return 1

//Absorbs the target DNA.
/datum/changeling/proc/absorb_dna(mob/living/carbon/T)
	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	absorbed_dna |= T.dna //And add the target DNA to our absorbed list.
	absorbedcount++ //all that done, let's increment the objective counter.

//Checks if the target DNA is valid and absorbable.
/datum/changeling/proc/can_absorb_dna(mob/living/carbon/U, mob/living/carbon/T)
	if(T)
		if(NOCLONE in T.mutations || HUSK in T.mutations)
			U << "<span class='warning'>DNA of [T] is ruined beyond usability!</span>"
			return 0

		if(T:species.flags & IS_SYNTHETIC || T:species.flags & IS_PLANT)
			U << "<span class='warning'>[T] is not compatible with our biology.</span>"
			return 0

		if(T:species.flags & NO_SCAN)
			src << "<span class='warning'>We do not know how to parse this creature's DNA!</span>"
			return 0

		for(var/datum/dna/D in absorbed_dna)
			if(T.dna.uni_identity == D.uni_identity)
				if(T.dna.struc_enzymes == D.struc_enzymes)
					if(T.dna.real_name == D.real_name)
						if(T.dna.mutantrace == D.mutantrace)
							U << "<span class='warning'>We already have that DNA in storage.</span>"
							return 0
	return 1
/*
/obj/effect/proc_holder/changeling/absorbDNA/can_sting(var/mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		user << "<span class='warning'>We are already absorbing!</span>"
		return

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		user << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>"
		return
	if(!G.state == GRAB_KILL)
		user << "<span class='warning'>We must have a tighter grip to absorb this creature.</span>"
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/absorbDNA/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user << "<span class='notice'>We extend a proboscis.</span>"
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
			if(3)
				user << "<span class='notice'>We stab [target] with the proboscis.</span>"
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>")
				target << "<span class='danger'>You feel a sharp stabbing pain!</span>"
				target.take_overall_damage(40)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			user << "<span class='warning'>Our absorption of [target] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	user << "<span class='notice'>We have absorbed [target]!</span>"
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	target << "<span class='danger'>You have been absorbed by the changeling!</span>"

//	changeling.absorb_dna(target)
	target.dna.real_name = target.real_name //Set this again, just to be sure that it's properly set.
	changeling.absorbed_dna |= target.dna

	//Steal all of their languages!
	for(var/language in target.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	var/mob/living/carbon/C = src
	C.changeling_update_languages(changeling.absorbed_languages)

	//Steal their species!
	if(target.species && !(target.species.name in changeling.absorbed_species))
		changeling.absorbed_species += target.species.name

	if(user.nutrition < 400) user.nutrition = min((user.nutrition + target.nutrition), 400)
	if(target.mind)//if the victim has got a mind
		target.mind.show_memory(src, 0) //I can read your mind, kekeke. Output all their notes.
		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			if(target.mind.changeling.absorbed_dna)
				for(var/dna_data in target.mind.changeling.absorbed_dna)	//steal all their loot
					if(dna_data in changeling.absorbed_dna)
						continue
					changeling.absorbed_dna += dna_data

/*		if(T.mind.changeling.purchasedpowers)
			for(var/datum/power/changeling/Tp in T.mind.changeling.purchasedpowers)
				if(Tp in changeling.purchasedpowers)
					continue
				else
					changeling.purchasedpowers += Tp

					if(!Tp.isVerb)
						call(Tp.verbpath)()
					else
						src.make_changeling() */


				changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
				changeling.absorbedcount += target.mind.changeling.absorbedcount
				changeling.geneticpoints += target.mind.changeling.geneticpoints

				target.mind.changeling.absorbed_dna.len = 1
				target.mind.changeling.absorbedcount = 0
				target.mind.changeling.chem_charges = 0
				target.mind.changeling.geneticpoints = 0

		else
			changeling.chem_charges += 10

	changeling.geneticpoints += 2
	changeling.isabsorbing = 0
//	changeling.canrespec = 1

	target.death(0)
	target.Drain()
	return 1

 */