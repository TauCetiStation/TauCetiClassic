//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//	generic ribcage surgery step datum
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/open_encased/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && !(BP.status & ORGAN_ROBOT) && BP.encased && BP.open >= 2

//////////////////////////////////////////////////////////////////
//	ribcage sawing surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased/saw
	allowed_tools = list(
		 /obj/item/weapon/circular_saw = 100
		,/obj/item/weapon/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/open_encased/saw/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.open == 2

/datum/surgery_step/open_encased/saw/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	user.visible_message("[user] begins to cut through [target]'s [BP.encased] with \the [tool].",
		                     "You begin to cut through [target]'s [BP.encased] with \the [tool].")
	target.custom_pain("Something hurts horribly in your [BP.name]!", 100, BP = BP)
	..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	user.visible_message("<span class='notice'>[user] has cut [target]'s [BP.encased] open with \the [tool].</span>",
		                   "<span class='notice'>You have cut [target]'s [BP.encased] open with \the [tool].</span>")
	BP.open = 2.5

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [BP.encased] with \the [tool]!</span>",
		                     "<span class='warning'>Your hand slips, cracking [target]'s [BP.encased] with \the [tool]!</span>")
	BP.take_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
	BP.fracture()

//////////////////////////////////////////////////////////////////
//	ribcage splitting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased/retract
	allowed_tools = list(
		 /obj/item/weapon/retractor = 100
		,/obj/item/weapon/crowbar = 75
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/open_encased/retract/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.open == 2.5

/datum/surgery_step/open_encased/retract/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "[user] starts to force open the [BP.encased] in [target]'s [BP.name] with \the [tool]."
	var/self_msg = "You start to force open the [BP.encased] in [target]'s [BP.name] with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [BP.name]!", 100, BP = BP)
	..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "<span class='notice'>[user] forces open [target]'s [BP.encased] with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You force open [target]'s [BP.encased] with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	BP.open = 3

	// Whoops!
	if(prob(10))
		BP.fracture()

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "<span class='warning'>[user]'s hand slips, cracking [target]'s [BP.encased]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, cracking [target]'s [BP.encased]!</span>"
	user.visible_message(msg, self_msg)

	BP.take_damage(20, used_weapon = tool)
	BP.fracture()

//////////////////////////////////////////////////////////////////
//	ribcage closing surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased/close
	allowed_tools = list(
		 /obj/item/weapon/retractor = 100
		,/obj/item/weapon/crowbar = 75
	)


	min_duration = 20
	max_duration = 40

/datum/surgery_step/open_encased/close/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.open == 3

/datum/surgery_step/open_encased/close/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "[user] starts bending [target]'s [BP.encased] back into place with \the [tool]."
	var/self_msg = "You start bending [target]'s [BP.encased] back into place with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!", 100, BP = BP)
	..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "<span class='notice'>[user] bends [target]'s [BP.encased] back into place with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You bend [target]'s [BP.encased] back into place with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	BP.open = 2.5

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "<span class='warning'>[user]'s hand slips, bending [target]'s [BP.encased] the wrong way!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, bending [target]'s [BP.encased] the wrong way!</span>"
	user.visible_message(msg, self_msg)

	BP.take_damage(20, used_weapon = tool)
	BP.fracture()

	if(BP.organs && BP.organs.len && prob(40))
		var/obj/item/organ/IO = pick(BP.organs)
		user.visible_message("<span class='danger'>A wayward piece of [target]'s [BP.encased] pierces \his [IO.name]!</span>")
		IO.bruise()

//////////////////////////////////////////////////////////////////
//	ribcage mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased/mend
	allowed_tools = list(
		 /obj/item/weapon/bonegel = 100
		,/obj/item/weapon/screwdriver = 75
	)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/open_encased/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.open == 2.5

/datum/surgery_step/open_encased/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =  "[user] starts applying \the [tool] to [target]'s [BP.encased]."
	var/self_msg = "You start applying \the [tool] to [target]'s [BP.encased]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!", 100, BP = BP)
	..()

/datum/surgery_step/open_encased/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/msg =   "<span class='notice'>[user] applied \the [tool] to [target]'s [BP.encased].</span>"
	var/self_msg = "<span class='notice'>You applied \the [tool] to [target]'s [BP.encased].</span>"
	user.visible_message(msg, self_msg)

	BP.open = 2

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased/remove_embryo
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)
	blood_level = 2

	min_duration = 80
	max_duration = 100

/datum/surgery_step/open_encased/remove_embryo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/embryo = 0
	for(var/obj/item/alien_embryo/A in target)
		embryo = 1
		break
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.open >= (BP.encased ? 3 : 2) && embryo

/datum/surgery_step/open_encased/remove_embryo/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
	var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!",100)
	..()

/datum/surgery_step/open_encased/remove_embryo/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user] rips the larva out of [target]'s ribcage!",
						 "You rip the larva out of [target]'s ribcage!")

	for(var/obj/item/alien_embryo/A in target)
		A.loc = A.loc.loc
