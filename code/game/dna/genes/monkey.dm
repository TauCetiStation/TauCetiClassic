/datum/dna/gene/monkey
	name = "Monkey"

/datum/dna/gene/monkey/New()
	block = MONKEYBLOCK

/datum/dna/gene/monkey/can_activate(mob/living/carbon/C,flags)
	return istype(C) && C.species.backward_form && !C.monkeyizing

/datum/dna/gene/monkey/activate(mob/living/carbon/C, connected, flags)
	if(C.monkeyizing || !(C.species.name in list(S_HUMAN, S_UNATHI, S_SKRELL, S_TAJARAN)))
		//if(!C.monkeyizing)
		//	testing("Cannot monkey-ify [M], specie is [M.species.name].")
		return

	do_transform(C)

	C.real_name = lowertext(C.species.name)
	var/obj/item/organ/brain/BRAIN = C.organs_by_name[BP_BRAIN]
	if(BRAIN)
		BRAIN.is_advanced_tool_user = FALSE

/datum/dna/gene/monkey/deactivate(mob/living/carbon/C, connected, flags)
	if(C.monkeyizing || !(C.species.name in list(S_MONKEY, S_MONKEY_U, S_MONKEY_S, S_MONKEY_T)))
		//if(!C.monkeyizing)
		//	testing("Cannot monkey-ify [M], specie is [M.species.name].")
		return

	do_transform(C)

	C.real_name = C.dna.real_name
	var/obj/item/organ/brain/BRAIN = C.organs_by_name[BP_BRAIN]
	if(BRAIN)
		BRAIN.is_advanced_tool_user = initial(BRAIN.is_advanced_tool_user)

/datum/dna/gene/monkey/proc/do_transform(mob/living/carbon/C)
	C.monkeyizing = TRUE
	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in C)
		implants += W

	for(var/obj/item/W in (C.contents-implants))
		C.dropItemToGround(W)

	if(C.species.backward_form)
		C.set_species(C.species.backward_form)
	//else probably not needed with hardcoded species check
	//	C.gib() //Trying to change the species of a creature with no backward_form var set is messy.
	//	return

	var/list/bodyparts = C.bodyparts.Copy()
	while(bodyparts.len)
		if(prob(rand(17,35)) && C.can_feel_pain())
			C.emote("scream",,, 1)
		var/obj/item/bodypart/BP = pick(bodyparts)
		bodyparts -= BP
		C.update_bodypart(BP.body_zone)
		sleep(rand(5,15))

	C.monkeyizing = FALSE
