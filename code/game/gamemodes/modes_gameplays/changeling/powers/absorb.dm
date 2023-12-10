/obj/effect/proc_holder/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	genomecost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/absorbDNA/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE

	if(HAS_TRAIT_FROM(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT))
		to_chat(user, "<span class='warning'>We are already absorbing!</span>")
		return FALSE

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return FALSE
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return FALSE

	var/mob/living/carbon/target = G.affecting
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/absorbDNA/sting_action(mob/living/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	ADD_TRAIT(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT)
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				if(target.mind)
					to_chat(user, "<span class='notice'>This creature has mind. We will become one.</span>")
				else
					to_chat(user, "<span class='notice'>This creature is mindless. We'll just satisfy our hunger.</span>")
				to_chat(user, "<span class='notice'>We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We extend a proboscis.</span>")
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
			if(3)
				to_chat(user, "<span class='notice'>We stab [target] with the proboscis.</span>")
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>")
				to_chat(target, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				var/obj/item/organ/external/BP = target.get_bodypart(user.get_targetzone())
				if(BP.take_damage(39, null, DAM_SHARP, "large organic needle"))
					continue

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our absorption of [target] has been interrupted!</span>")
			REMOVE_TRAIT(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT)
			return FALSE

	to_chat(user, "<span class='notice'>We have absorbed [target]!</span>")
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	to_chat(target, "<span class='danger'>You have been absorbed by the changeling!</span>")

	changeling.absorb_dna(target)

	var/nutr = user.get_satiation()
	if(nutr < NUTRITION_LEVEL_NORMAL)
		user.nutrition += min(target.nutrition, NUTRITION_LEVEL_NORMAL - nutr)

	//Steal all of their languages!
	for(var/language in target.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	user.changeling_update_languages(changeling.absorbed_languages)

	//Steal their species!
	if(target.species && !(target.species.name in changeling.absorbed_species))
		changeling.absorbed_species += target.species.name

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(user) //I can read your mind, kekeke. Output all their notes.
		changeling.geneticpoints += 2
		user.mind.skills.transfer_skills(target.mind)
		var/datum/role/changeling/C = target.mind.GetRoleByType(/datum/role/changeling)
		if(C)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(C.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += C.absorbedcount
			if(C.absorbed_dna)
				for(var/dna_data in C.absorbed_dna)	//steal all their loot
					if(dna_data in changeling.absorbed_dna)
						continue
					changeling.absorbed_dna += dna_data
				C.absorbed_dna.len = 1
			for(var/mob/living/parasite/essence/E in C.essences)
				E.flags_allowed = (ESSENCE_HIVEMIND | ESSENCE_PHANTOM | ESSENCE_POINT | ESSENCE_SPEAK_TO_HOST)
				E.self_voice = FALSE
				if(E.phantom)
					E.phantom.hide_phantom()
				E.changeling = changeling
				E.transfer(user)
			C.essences.Cut()


			changeling.geneticpoints += C.geneticpoints
			C.absorbedcount = 0
		new /mob/living/parasite/essence(user, user, target)

	else
		changeling.geneticpoints += 0.5
		changeling.chem_charges += 10

	changeling.absorbedamount++
	REMOVE_TRAIT(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT)
	target.blood_remove(BLOOD_VOLUME_MAXIMUM) // We are vamplings, so we drink blood!
	target.death(0)
	target.Drain()

	changeling.handle_absorbing()
	return TRUE

//Absorbs the target DNA.
/datum/role/changeling/proc/absorb_dna(mob/living/carbon/T)
	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	absorbed_dna |= T.dna //And add the target DNA to our absorbed list.
	absorbedcount++ //all that done, let's increment the objective counter.

//Checks if the target DNA is valid and absorbable.
/datum/role/changeling/proc/can_absorb_dna(mob/living/carbon/U, mob/living/carbon/C)
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
					if(T.dna.original_character_name == D.original_character_name)
						to_chat(U, "<span class='warning'>We already have that DNA in storage.</span>")
						return FALSE
	return TRUE
