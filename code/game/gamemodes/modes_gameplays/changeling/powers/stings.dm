/obj/effect/proc_holder/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby."
	var/sting_icon = null
	var/ranged = 1

/obj/effect/proc_holder/changeling/sting/on_sting_choose(mob/user)
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	if(!(C.chosen_sting))
		set_sting(user)
	else
		unset_sting(user)

/obj/effect/proc_holder/changeling/sting/proc/set_sting(mob/user)
	to_chat(user, "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>")
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	C.chosen_sting = src
	C.lingstingdisplay.icon_state = sting_icon
	C.lingstingdisplay.invisibility = INVISIBILITY_NONE

/obj/effect/proc_holder/changeling/sting/proc/unset_sting(mob/user)
	to_chat(user, "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>")
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	C.chosen_sting = null
	C.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/mob/living/carbon/proc/unset_sting()
	var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
	if(C && C.chosen_sting)
		C.chosen_sting.unset_sting(src)

/obj/effect/proc_holder/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return FALSE
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	if(!C.chosen_sting)
		to_chat(user, "We haven't prepared our sting yet!")
	if(!iscarbon(target))
		return FALSE
	if(!isturf(user.loc))
		return FALSE
	if(!AStar(user, target.loc, TYPE_PROC_REF(/turf, Distance), C.sting_range, simulated_only = FALSE))
		return FALSE //hope this ancient magic still works
	if(ischangeling(target))
		sting_feedback(user,target)
		take_chemical_cost(C)
		return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/sting/sting_feedback(mob/user, mob/living/target)
	if(!target)
		return
	if((get_dist(user, target) <= 1))
		to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	else
		to_chat(user, "<span class='notice'>We stealthily shoot [target.name] with sting.</span>")
	if(ischangeling(target))
		to_chat(target, "<span class='warning'>You feel a tiny prick.</span>")
	//	add_logs(user, target, "unsuccessfully stung")
	target.log_combat(user, "stinged with [name]")

/obj/effect/proc_holder/changeling/sting/proc/sting_fail(mob/user, mob/target)
	if(!target)
		return TRUE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit)
			var/obj/item/clothing/I = H.wear_suit
			if(I.pierce_protection & UPPER_TORSO)
				to_chat(user, "<span class='warning'>We broke our sting about our's armor!</span>")
				unset_sting(user)
				var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
				C.chem_charges -= rand(5,10)
				H.drip(10)
				return TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
		var/result = H.check_pierce_protection(BP) || H.isSynthetic(user.get_targetzone())
		if(result)
			if(result == NOLIMB)
				to_chat(user, "<span class='warning'>We missed! [target.name] has no [BP.name]!</span>")
			else
				to_chat(user, "<span class='warning'>We broke our sting about [target.name]'s [BP.name]!</span>")
				to_chat(target, "<span class='warning'>You feel a tiny push in your [BP.name]!</span>")
				if(ishuman(user))
					var/mob/living/carbon/human/HU = user
					HU.drip(10)
			unset_sting(user)
			var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
			C.chem_charges -= rand(5,10)

			return TRUE
		return FALSE

/obj/effect/proc_holder/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals that freeze them."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	sting_icon = "sting_cryo"
	button_icon_state = "sting_cryo"
	chemical_cost = 15
	genomecost = 1

/obj/effect/proc_holder/changeling/sting/cryo/sting_action(mob/user, mob/target)
	if(sting_fail(user,target))
		return FALSE
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("ice", 30)
	feedback_add_details("changeling_powers","CS")
	return TRUE

/obj/effect/proc_holder/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "Causes terror in the target."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	sting_icon = "sting_lsd"
	button_icon_state = "sting_lsd"
	chemical_cost = 15
	genomecost = 1

/obj/effect/proc_holder/changeling/sting/LSD/sting_action(mob/user, mob/living/carbon/target)
	if(sting_fail(user,target))
		return FALSE
	spawn(rand(300,600))
		if(target)
			target.hallucination = max(400, target.hallucination)
	feedback_add_details("changeling_powers","HS")
	return TRUE

/obj/effect/proc_holder/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	sting_icon = "sting_transform"
	button_icon_state = "sting_transform"
	chemical_cost = 40
	genomecost = 2
	var/datum/dna/selected_dna = null

/obj/effect/proc_holder/changeling/sting/transformation/set_sting(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.original_character_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	selected_dna = changeling.GetDNA(S)
	if(!selected_dna)
		return
	..()

/obj/effect/proc_holder/changeling/sting/transformation/can_sting(mob/user, mob/target)
	if(!..())
		return FALSE
	if((HUSK in target.mutations) || (NOCLONE in target.mutations))
		to_chat(user, "<span class='warning'>Our sting appears ineffective against its DNA.</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/sting/transformation/sting_action(mob/user, mob/target)
	if(sting_fail(user,target))
		return FALSE
	if(ismonkey(target))
		to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	target.visible_message("<span class='warning'>[target] transforms!</span>")
	//save original
	var/essence_name = target.dna.original_character_name
	target.dna = selected_dna.Clone()
	target.real_name = selected_dna.real_name
	//unchange this
	target.dna.original_character_name = essence_name
	domutcheck(target, null)
	target.UpdateAppearance()

	var/mob/living/carbon/human/H = target
	if(istype(H))
		H.fixblood(FALSE) // need to change blood DNA too

	feedback_add_details("changeling_powers","TS")
	return TRUE

/obj/effect/proc_holder/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	sting_icon = "sting_extract"
	button_icon_state = "sting_extract"
	chemical_cost = 25
	genomecost = 1
	ranged = 0

/obj/effect/proc_holder/changeling/sting/extract_dna/can_sting(mob/user, mob/living/carbon/target)
	if(..())
		var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
		return C.can_absorb_dna(user, target)

/obj/effect/proc_holder/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	if(sting_fail(user,target))
		return FALSE
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)

	target.dna.real_name = target.real_name
	changeling.absorbed_dna |= target.dna

	if(target.species && !(target.species.name in changeling.absorbed_species))
		changeling.absorbed_species += target.species.name

	for(var/language in target.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	user.changeling_update_languages(changeling.absorbed_languages)
	feedback_add_details("changeling_powers","ED")
	return TRUE

/obj/effect/proc_holder/changeling/sting/silence
	name = "Silence Sting"
	desc = "We silently sting a human, completely deafening and silencing them for a short time."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	sting_icon = "sting_mute"
	button_icon_state = "sting_mute"
	chemical_cost = 20
	genomecost = 1

/obj/effect/proc_holder/changeling/sting/silence/sting_action(mob/user, mob/living/carbon/target)
	if(sting_fail(user,target))
		return FALSE
	to_chat(target, "<span class='danger'>Your ears pop and begin ringing loudly!</span>")
	target.sdisabilities |= DEAF
	spawn(300)	target.sdisabilities &= ~DEAF
	target.silent += 30
	feedback_add_details("changeling_powers","MS")
	return TRUE

/obj/effect/proc_holder/changeling/sting/blind
	name = "Blind Sting"
	helptext = "Temporarily blinds the target."

	desc = "This sting completely blinds a target for a short time. The target does not notice they have been stung."
	sting_icon = "sting_blind"
	button_icon_state = "sting_blind"
	chemical_cost = 25
	genomecost = 1

/obj/effect/proc_holder/changeling/sting/blind/sting_action(mob/user, mob/target)
	if(sting_fail(user,target))
		return FALSE
	to_chat(target, "<span class='danger'>Your eyes burn horrifically!</span>")
	target.become_nearsighted(EYE_DAMAGE_TEMPORARY_TRAIT)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, cure_nearsighted), EYE_DAMAGE_TEMPORARY_TRAIT), 30 SECONDS, TIMER_STOPPABLE)
	target.eye_blind = 20
	target.blurEyes(40)
	feedback_add_details("changeling_powers","BS")
	return TRUE

/obj/effect/proc_holder/changeling/sting/unfat
	name = "Fat Sting"
	desc = "We silently sting a human, forcing them to rapidly metabolize their fat."
	button_icon_state = "sting_fat"
	helptext = ""
	sting_icon = "sting_fat"
	chemical_cost = 5
	genomecost = 1

/obj/effect/proc_holder/changeling/sting/unfat/sting_action(mob/user, mob/living/carbon/target)
	if(sting_fail(user,target))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_FAT))
		target.overeatduration = 0
		target.nutrition -= 100
		to_chat(target, "<span class='danger'>You feel a small prick as stomach churns violently and you become to feel skinnier.</span>")
	else
		target.overeatduration = 600
		target.nutrition += 100
		to_chat(target, "<span class='danger'>You feel a small prick as stomach churns violently and you become to feel blubbery.</span>")
	feedback_add_details("changeling_powers","US")
	return TRUE
