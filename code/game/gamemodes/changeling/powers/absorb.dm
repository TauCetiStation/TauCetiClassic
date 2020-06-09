/obj/effect/proc_holder/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim."
	chemical_cost = 0
	genomecost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/absorbDNA/can_sting(mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		to_chat(user, "<span class='warning'>We are already absorbing!</span>")
		return

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/absorbDNA/sting_action(mob/living/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(user, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We extend a proboscis.</span>")
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
			if(3)
				to_chat(user, "<span class='notice'>We stab [target] with the proboscis.</span>")
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>")
				to_chat(target, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				var/obj/item/organ/external/BP = target.get_bodypart(user.zone_sel.selecting)
				if(BP.take_damage(39, null, DAM_SHARP, "large organic needle"))
					continue

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our absorption of [target] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(user, "<span class='notice'>We have absorbed [target]!</span>")
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	to_chat(target, "<span class='danger'>You have been absorbed by the changeling!</span>")

	changeling.absorb_dna(target)

	if(user.get_nutrition() < 400) user.nutrition = min((user.nutrition + target.nutrition), 400)
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
		changeling.geneticpoints += 2

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += target.mind.changeling.absorbedcount
			if(target.mind.changeling.absorbed_dna)
				for(var/dna_data in target.mind.changeling.absorbed_dna)	//steal all their loot
					if(dna_data in changeling.absorbed_dna)
						continue
					changeling.absorbed_dna += dna_data
				target.mind.changeling.absorbed_dna.len = 1
			for(var/mob/living/parasite/essence/E in target.mind.changeling.essences)
				E.flags_allowed = (ESSENCE_HIVEMIND | ESSENCE_PHANTOM | ESSENCE_POINT | ESSENCE_SPEAK_TO_HOST)
				E.self_voice = FALSE
				if(E.phantom)
					E.phantom.hide_phantom()
				E.changeling = changeling
				E.transfer(user)
			target.mind.changeling.essences.Cut()


			changeling.geneticpoints += target.mind.changeling.geneticpoints
			target.mind.changeling.absorbedcount = 0
		new /mob/living/parasite/essence(user, user, target)

	else
		changeling.geneticpoints += 0.5
		changeling.chem_charges += 10

	changeling.isabsorbing = 0
	for(var/datum/reagent/blood/B in target.vessel.reagent_list) //We are vamplings, so we drink blood!
		if(B.id == "blood")
			B.volume = 0
	target.death(0)
	target.Drain()
	return 1

//Absorbs the target DNA.
/datum/changeling/proc/absorb_dna(mob/living/carbon/T)
	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	absorbed_dna |= T.dna //And add the target DNA to our absorbed list.
	absorbedcount++ //all that done, let's increment the objective counter.

//Checks if the target DNA is valid and absorbable.
/datum/changeling/proc/can_absorb_dna(mob/living/carbon/U, mob/living/carbon/C)
	if(C)
		if(!ishuman(C))
			to_chat(U, "<span class='warning'>[C] is too simple for absorption.</span>")
			return FALSE

		var/mob/living/carbon/human/T = C

		if((NOCLONE in T.mutations) || (HUSK in T.mutations))
			to_chat(U, "<span class='warning'>DNA of [T] is ruined beyond usability!</span>")
			return FALSE

		if(T.species.flags[IS_SYNTHETIC] || T.species.flags[IS_PLANT])
			to_chat(U, "<span class='warning'>[T] is not compatible with our biology.</span>")
			return FALSE

		if(T.species.flags[NO_SCAN])
			to_chat(src, "<span class='warning'>We do not know how to parse this creature's DNA!</span>")
			return FALSE

		for(var/datum/dna/D in absorbed_dna)
			if(T.dna.uni_identity == D.uni_identity)
				if(T.dna.struc_enzymes == D.struc_enzymes)
					if(T.dna.real_name == D.real_name)
						if(T.dna.mutantrace == D.mutantrace)
							to_chat(U, "<span class='warning'>We already have that DNA in storage.</span>")
							return FALSE
	return TRUE