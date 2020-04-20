//Procedures in this file: Inernal wound patching, Implant removal, Fixing groin organs in IPCs and Dioneae
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && (BP.status & ORGAN_ARTERY_CUT) && BP.open >= 2

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [BP.name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("The pain in [BP.name] is unbearable!",1)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has patched the damaged vein in [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You have patched the damaged vein in [target]'s [BP.name] with \the [tool].</span>")

	BP.status &= ~ORGAN_ARTERY_CUT
	if (ishuman(user) && prob(40))
		var/mob/living/carbon/human/H = user
		H.bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//					GROIN ORGAN PATCHING						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/groin_organs
	priority = 3
	can_infect = 0
	blood_level = 1
	allowed_species = list(DIONA, IPC) // Just so you can fail on fixing IPC's groin organs.

/datum/surgery_step/groin_organs/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(target_zone != BP_GROIN)
		return FALSE
	var/obj/item/organ/external/groin = target.get_bodypart(BP_GROIN)
	if(!groin)
		return FALSE
	if(groin.open < 1)
		return FALSE
	for(var/obj/item/organ/internal/IO in groin.bodypart_organs) // If they ain't got nothing to fix, don't.
		return TRUE
	return FALSE

/datum/surgery_step/groin_organs/fixing
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,
	/obj/item/stack/medical/bruise_pack = 20,
	/obj/item/stack/medical/bruise_pack/tajaran = 70
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/groin_organs/fixing/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/is_groin_organ_damaged = FALSE
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0)
			is_groin_organ_damaged = TRUE
			break
	return is_groin_organ_damaged

/datum/surgery_step/groin_organs/fixing/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.robotic < 2)
				user.visible_message("[user] starts treating damage to [target]'s [IO.name] with [tool_name].",
				"You start treating damage to [target]'s [IO.name] with [tool_name]." )
			else
				user.visible_message("<span class='notice'>[user] attempts to repair [target]'s mechanical [IO.name] with [tool_name]...</span>",
				"<span class='notice'>You attempt to repair [target]'s mechanical [IO.name] with [tool_name]...</span>")

	if(target.species && target.species.flags[NO_PAIN])
		to_chat(target, "You notice slight movement in your groin.")
	else
		target.custom_pain("The pain in your groin is living hell!",1)
	..()

/datum/surgery_step/groin_organs/fixing/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.robotic < 2)
				user.visible_message("<span class='notice'>[user] treats damage to [target]'s [IO.name] with [tool_name].</span>",
				"<span class='notice'>You treat damage to [target]'s [IO.name] with [tool_name].</span>" )
				IO.damage = 0
			else
				user.visible_message("<span class='notice'>[user] pokes [target]'s mechanical [IO.name] with [tool_name]...</span>",
				"<span class='notice'>You poke [target]'s mechanical [IO.name] with [tool_name]...</span> <span class='warning'>For no effect, since it's robotic.</span>")

/datum/surgery_step/groin_organs/fixing/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s groin with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s groin with \the [tool]!</span>")
	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		if(istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			target.adjustToxLoss(7)
		else
			dam_amt = 5
			target.adjustToxLoss(10)
			BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)

	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			IO.take_damage(dam_amt,0)

/datum/surgery_step/groin_organs/fixing_robot //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)

	allowed_species = list(IPC)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/groin_organs/fixing_robot/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/is_groin_organ_damaged = FALSE
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.robotic == 2)
			is_groin_organ_damaged = TRUE
			break
	return is_groin_organ_damaged

/datum/surgery_step/groin_organs/fixing_robot/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.robotic == 2)
			user.visible_message("[user] starts mending the mechanisms on [target]'s [IO] with \the [tool].",
			"You start mending the mechanisms on [target]'s [IO] with \the [tool]." )
			continue
	if(target.species && target.species.flags[NO_PAIN])
		to_chat(target, "You notice slight movement in your groin.")
	else
		target.custom_pain("The pain in your groin is living hell!",1)
	..()

/datum/surgery_step/groin_organs/fixing_robot/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.robotic == 2)
			user.visible_message("<span class='notice'>[user] repairs [target]'s [IO] with \the [tool].</span>",
			"<span class='notice'>You repair [target]'s [IO] with \the [tool].</span>" )
			IO.damage = 0

/datum/surgery_step/groin_organs/fixing_robot/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [IO], gumming it up!</span>",
		"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [IO], gumming it up!</span>")
		var/dam_amt = 2
		if(istype(tool, /obj/item/stack/nanopaste) || istype(tool, /obj/item/weapon/bonegel))
			BP.take_damage(0, 6, used_weapon = tool)

		else if(iswrench(tool))
			BP.take_damage(12, 0, used_weapon = tool)
			BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)

		if(IO.damage > 0 && IO.robotic == 2)
			IO.take_damage(dam_amt,0)
