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

	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
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
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
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
				var/obj/item/organ/external/BP = target.get_bodypart(user.get_targetzone())
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

	check_overeating(user)
	var/nutr = user.get_nutrition()
	if(nutr < 400)
		user.nutrition += min(target.nutrition, 400 - nutr)

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

	changeling.isabsorbing = 0
	target.blood_remove(BLOOD_VOLUME_MAXIMUM) // We are vamplings, so we drink blood!
	target.death(0)
	target.Drain()
	return 1

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
					if(T.dna.real_name == D.real_name)
						if(T.dna.mutantrace == D.mutantrace)
							to_chat(U, "<span class='warning'>We already have that DNA in storage.</span>")
							return FALSE
	return TRUE


#define OVEREATING_AMOUNT 6
/obj/effect/proc_holder/changeling/absorbDNA/proc/check_overeating(mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)

	if(changeling.absorbedcount == OVEREATING_AMOUNT/2)
		to_chat(user, "<span class='warning'>Absorbing that many made us realise that we are halway to becoming a threat to all - even ourselves. We should be more careful with absorbings.</span>")

	if(changeling.absorbedcount == OVEREATING_AMOUNT-1)
		to_chat(user, "<span class='warning'>We feel like we're near the edge to transforming to something way more brutal and inhuman - <B>and there will be no way back</B>.</span>")

	if(changeling.absorbedcount == OVEREATING_AMOUNT)
		to_chat(user, "<span class='danger'>We feel our flesh mutate, ripping all our belongings from our body. Additional limbs burst out of our chest along with deadly claws - we've become <B>The Abomination</B>. The end approaches.</span>")
		for(var/obj/item/I in user) //drops all items
			user.drop_from_inventory(I)
		user.regenerate_icons()
		user.Stun(10)
		sleep(10)

		user.set_species(ABOMINATION)
		user.name = "[changeling.changelingID]"
		user.real_name = user.name

		for(var/mob/M in player_list)
			if(!isnewplayer(M))
				to_chat(M, "<font size='10' color='red'><b>A terrible roar is coming from somewhere around the station.</b></font>")
				M.playsound_local(null, 'sound/antag/abomination_start.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

#undef OVEREATING_AMOUNT
