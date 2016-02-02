/obj/effect/proc_holder/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby."
	var/sting_icon = null
	var/ranged = 1

/obj/effect/proc_holder/changeling/sting/Click()
	var/mob/user = usr
	if(!user || !user.mind || !user.mind.changeling)
		return
	if(!(user.mind.changeling.chosen_sting))
		set_sting(user)
	else
		unset_sting(user)
	return

/obj/effect/proc_holder/changeling/sting/proc/set_sting(var/mob/user)
	user << "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>"
	user.mind.changeling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/obj/effect/proc_holder/changeling/sting/proc/unset_sting(var/mob/user)
	user << "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>"
	user.mind.changeling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = 101

/mob/living/carbon/proc/unset_sting()
	if(mind && mind.changeling && mind.changeling.chosen_sting)
		src.mind.changeling.chosen_sting.unset_sting(src)

/obj/effect/proc_holder/changeling/sting/can_sting(var/mob/user, var/mob/target)


	if(!..())
		return
	if(!user.mind.changeling.chosen_sting)
		user << "We haven't prepared our sting yet!"
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(!ranged && get_dist(user, target) > 1)
		return
	if(get_dist(user, target) > (user.mind.changeling.sting_range))
		return //sanity check as AStar is still throwing insane stunts
	if(!AStar(user.loc, target.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, user.mind.changeling.sting_range))
		return //hope this ancient magic still works
	if(target.mind && target.mind.changeling)
		sting_feedback(user,target)
		take_chemical_cost(user.mind.changeling)
		return
	return 1

/obj/effect/proc_holder/changeling/sting/sting_feedback(var/mob/user, var/mob/target)
	if(!target)
		return
	if((get_dist(user, target) <= 1))
		user << "<span class='notice'>We stealthily sting [target.name].</span>"
	else
		user << "<span class='notice'>We stealthily shoot [target.name] with sting.</span>"
	if(target.mind && target.mind.changeling)
		target << "<span class='warning'>You feel a tiny prick.</span>"
	//	add_logs(user, target, "unsuccessfully stung")
	msg_admin_attack("[key_name(user)] used [src] on [key_name(target)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	return 1

/obj/effect/proc_holder/changeling/sting/proc/sting_fail(var/mob/user, var/mob/target)
	if(!target)
		return
	if(ishuman(target))
		var/datum/organ/external/affecting = target:get_organ(user.zone_sel.selecting)
		if(target:check_thickmaterial(affecting))
			user << "<span class='warning'>We broke our sting about [target.name]'s [user.zone_sel.selecting]!</span>"
			target << "<span class='warning'>You feel a tiny push in your [user.zone_sel.selecting]!</span>"
			unset_sting(user)
			user.mind.changeling.chem_charges -= rand(5,10)
			if(ishuman(user))
				user:drip(10)
			return 1
		else
			return 0

obj/effect/proc_holder/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals that freeze them."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	sting_icon = "sting_cryo"
	chemical_cost = 15
	genomecost = 2

/obj/effect/proc_holder/changeling/sting/cryo/sting_action(var/mob/user, var/mob/target)
	if(sting_fail(user,target))
		return 0
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("ice", 30)
	feedback_add_details("changeling_powers","CS")
	return 1

obj/effect/proc_holder/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "Causes terror in the target."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	sting_icon = "sting_lsd"
	chemical_cost = 15
	genomecost = 3

/obj/effect/proc_holder/changeling/sting/LSD/sting_action(var/mob/user, var/mob/living/carbon/target)
	if(sting_fail(user,target))
		return 0
	spawn(rand(300,600))
		if(target)
			target.hallucination = max(400, target.hallucination)
	feedback_add_details("changeling_powers","HS")
	return 1

/obj/effect/proc_holder/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	sting_icon = "sting_transform"
	chemical_cost = 40
	genomecost = 3
	var/datum/dna/selected_dna = null

/obj/effect/proc_holder/changeling/sting/transformation/Click()
	var/mob/user = usr
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	selected_dna = changeling.GetDNA(S)
	if(!selected_dna)
		return
	..()

/obj/effect/proc_holder/changeling/sting/transformation/can_sting(var/mob/user, var/mob/target)
	if(!..())
		return
	if((HUSK in target.mutations) || (NOCLONE in target.mutations))
		user << "<span class='warning'>Our sting appears ineffective against its DNA.</span>"
		return 0
	return 1

/obj/effect/proc_holder/changeling/sting/transformation/sting_action(var/mob/user, var/mob/target)
	if(sting_fail(user,target))
		return 0
	if(ismonkey(target))
		user << "<span class='notice'>We stealthily sting [target.name].</span>"
	target.visible_message("<span class='warning'>[target] transforms!</span>")
	target.dna = selected_dna.Clone()
	target.real_name = selected_dna.real_name
	domutcheck(target, null)
	target.UpdateAppearance()
	feedback_add_details("changeling_powers","TS")
	return 1

obj/effect/proc_holder/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	sting_icon = "sting_extract"
	chemical_cost = 25
	genomecost = 2
	ranged = 0

/obj/effect/proc_holder/changeling/sting/extract_dna/can_sting(var/mob/user, var/mob/living/carbon/target)
	if(..())
		return user.mind.changeling.can_absorb_dna(user, target)

/obj/effect/proc_holder/changeling/sting/extract_dna/sting_action(var/mob/user, var/mob/living/carbon/human/target)
	if(sting_fail(user,target))
		return 0
	var/datum/changeling/changeling = user.mind.changeling

	target.dna.real_name = target.real_name
	changeling.absorbed_dna |= target.dna

	if(target.species && !(target.species.name in changeling.absorbed_species))
		changeling.absorbed_species += target.species.name

	for(var/language in target.languages)
		if(!(language in user.mind.changeling.absorbed_languages))
			changeling.absorbed_languages += language

	user.changeling_update_languages(changeling.absorbed_languages)
	feedback_add_details("changeling_powers","ED")
	return 1

obj/effect/proc_holder/changeling/sting/silence
	name = "Silence Sting"
	desc = "We silently sting a human, completely deafening and silencing them for a short time."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	sting_icon = "sting_mute"
	chemical_cost = 20
	genomecost = 4

/obj/effect/proc_holder/changeling/sting/silence/sting_action(var/mob/user, var/mob/living/carbon/target)
	if(sting_fail(user,target))
		return 0
	target << "<span class='danger'>Your ears pop and begin ringing loudly!</span>"
	target.sdisabilities |= DEAF
	spawn(300)	target.sdisabilities &= ~DEAF
	target.silent += 30
	feedback_add_details("changeling_powers","MS")
	return 1

obj/effect/proc_holder/changeling/sting/blind
	name = "Blind Sting"
	helptext = "Temporarily blinds the target."

	desc = "This sting completely blinds a target for a short time. The target does not notice they have been stung."
	sting_icon = "sting_blind"
	chemical_cost = 25
	genomecost = 2

/obj/effect/proc_holder/changeling/sting/blind/sting_action(var/mob/user, var/mob/target)
	if(sting_fail(user,target))
		return 0
	target << "<span class='danger'>Your eyes burn horrifically!</span>"
	target.disabilities |= NEARSIGHTED
	spawn(300)	target.disabilities &= ~NEARSIGHTED
	target.eye_blind = 20
	target.eye_blurry = 40
	feedback_add_details("changeling_powers","BS")
	return 1

/obj/effect/proc_holder/changeling/sting/paralysis
	name = "Paralysis Sting"
	helptext = "Temporarily paralyse the target."
	desc = "We silently sting a human, paralyzing them for a short time."
	sting_icon = "sting_paralyse"
	chemical_cost = 30
	genomecost = 8

/obj/effect/proc_holder/changeling/sting/paralysis/sting_action(var/mob/user, var/mob/living/carbon/target)
	if(sting_fail(user,target))
		return 0
	target << "<span class='danger'>Your muscles begin to painfully tighten.</span>"
	target.Weaken(20)
	feedback_add_details("changeling_powers","PS")
	return 1

/obj/effect/proc_holder/changeling/sting/death
	name = "Death Sting"
	helptext = "Causes spasms onto death."
	desc = "We silently sting a human, filling him with potent chemicals. His rapid death is all but assured."
	sting_icon = "sting_death"
	chemical_cost = 40
	genomecost = 10

/obj/effect/proc_holder/changeling/sting/death/sting_action(var/mob/user, var/mob/living/carbon/target)
	if(sting_fail(user,target))
		return 0
	target << "<span class='danger'>You feel a small prick and your chest becomes tight.</span>"
	target.silent = 15
	if(target.reagents)
		target.reagents.add_reagent("cryptobiolin", 20)
	spawn(50)
		if(target && target.reagents)
			target.reagents.add_reagent("lexorin", 20)
			target.reagents.add_reagent("toxin", 20)
			target.reagents.add_reagent("radium", 20)
			target.reagents.add_reagent("phoron", 20)
			target.reagents.add_reagent("pacid", 20)
	feedback_add_details("changeling_powers","DTHS")
	return 1

obj/effect/proc_holder/changeling/sting/unfat
	name = "Fat Sting"
	desc = "We silently sting a human, forcing them to rapidly metabolize their fat."
	helptext = ""
	sting_icon = "sting_fat"
	chemical_cost = 5
	genomecost = 1

/obj/effect/proc_holder/changeling/sting/unfat/sting_action(var/mob/user, var/mob/living/carbon/target)
	if(sting_fail(user,target))
		return 0
	if(FAT in target.mutations)
		target.overeatduration = 0
		target.nutrition -= 100
		target << "<span class='danger'>You feel a small prick as stomach churns violently and you become to feel skinnier.</span>"
	else
		target.overeatduration = 600
		target.nutrition += 100
		target << "<span class='danger'>You feel a small prick as stomach churns violently and you become to feel blubbery.</span>"
	feedback_add_details("changeling_powers","US")
	return 1
