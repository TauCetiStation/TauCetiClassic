//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	return target_zone == BP_CHEST

/datum/surgery_step/ribcage/saw_ribcage
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/ribcage/saw_ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return target.op_stage.ribcage == 0 && BP.open >= 2

/datum/surgery_step/ribcage/saw_ribcage/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cut through [target]'s ribcage with \the [tool].", \
	"You begin to cut through [target]'s ribcage with \the [tool].")
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/ribcage/saw_ribcage/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has cut [target]'s ribcage open with \the [tool].</span>",		\
	"<span class='notice'>You have cut [target]'s ribcage open with \the [tool].</span>")
	target.op_stage.ribcage = 1

/datum/surgery_step/ribcage/saw_ribcage/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s ribcage with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cracking [target]'s ribcage with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)


/datum/surgery_step/ribcage/retract_ribcage
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ribcage/retract_ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 1

/datum/surgery_step/ribcage/retract_ribcage/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "[user] starts to force open the ribcage in [target]'s torso with \the [tool]."
	var/self_msg = "You start to force open the ribcage in [target]'s torso with \the [tool]."
	user.visible_message(msg, self_msg)
	if(!(target.species && target.species.flags[NO_PAIN]))
		target.custom_pain("Something hurts horribly in your chest!",1)
	else
		target.custom_pain("You notice movement inside your chest!",1)
	..()

/datum/surgery_step/ribcage/retract_ribcage/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class='notice'>[user] forces open [target]'s ribcage with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You force open [target]'s ribcage with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	target.op_stage.ribcage = 2
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.open = 3

	// Whoops!
	if(prob(10))
		BP.fracture()

/datum/surgery_step/ribcage/retract_ribcage/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class='warning'>[user]'s hand slips, breaking [target]'s ribcage!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, breaking [target]'s ribcage!</span>"
	user.visible_message(msg, self_msg)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, used_weapon = tool)

/datum/surgery_step/ribcage/close_ribcage
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)


	min_duration = 20
	max_duration = 40

/datum/surgery_step/ribcage/close_ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 2

/datum/surgery_step/ribcage/close_ribcage/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "[user] starts bending [target]'s ribcage back into place with \the [tool]."
	var/self_msg = "You start bending [target]'s ribcage back into place with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/ribcage/close_ribcage/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class='notice'>[user] bends [target]'s ribcage back into place with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You bend [target]'s ribcage back into place with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	target.op_stage.ribcage = 1
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.open = 2

/datum/surgery_step/ribcage/close_ribcage/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class='warning'>[user]'s hand slips, bending [target]'s ribs the wrong way!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, bending [target]'s ribs the wrong way!</span>"
	user.visible_message(msg, self_msg)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	BP.fracture()
	BP.take_damage(20, 0, used_weapon = tool)
	if (prob(40))
		user.visible_message("<span class='warning'>A rib pierces the lung!</span>")
		target.rupture_lung()

/datum/surgery_step/ribcage/mend_ribcage
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/stack/rods = 50
	)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/ribcage/mend_ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 1

/datum/surgery_step/ribcage/mend_ribcage/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "[user] starts applying \the [tool] to [target]'s ribcage."
	var/self_msg = "You start applying \the [tool] to [target]'s ribcage."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/ribcage/mend_ribcage/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class='notice'>[user] applied \the [tool] to [target]'s ribcage.</span>"
	var/self_msg = "<span class='notice'>You applied \the [tool] to [target]'s ribcage.</span>"
	user.visible_message(msg, self_msg)

	target.op_stage.ribcage = 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.open = 1

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage/remove_embryo
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,
	/obj/item/weapon/wirecutters = 75,
	/obj/item/weapon/kitchen/utensil/fork = 50
	)
	blood_level = 2

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ribcage/remove_embryo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return (locate(/obj/item/alien_embryo) in target) && ..() && target.op_stage.ribcage == 2

/datum/surgery_step/ribcage/remove_embryo/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
	var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/ribcage/remove_embryo/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user] rips the larva out of [target]'s ribcage!</span>",
						 "You rip the larva out of [target]'s ribcage!")

	for(var/obj/item/alien_embryo/A in target)
		A.loc = A.loc.loc


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage/fix_chest_internal
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,
	/obj/item/stack/medical/bruise_pack = 20,
	/obj/item/stack/medical/bruise_pack/tajaran = 70
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/ribcage/fix_chest_internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	if(target.op_stage.ribcage != 2)
		return FALSE
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0)
			return TRUE
	return FALSE

/datum/surgery_step/ribcage/fix_chest_internal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.robotic < 2)
				user.visible_message("[user] starts treating damage to [target]'s [IO.name] with [tool_name].", \
				"You start treating damage to [target]'s [IO.name] with [tool_name]." )
			else
				user.visible_message("<span class='notice'>[user] attempts to repair [target]'s mechanical [IO.name] with [tool_name]...</span>", \
				"<span class='notice'>You attempt to repair [target]'s mechanical [IO.name] with [tool_name]...</span>")

	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/ribcage/fix_chest_internal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.robotic < 2)
				user.visible_message("[user] treats damage to [target]'s [IO.name] with [tool_name].", \
				"<span class='notice'>You treat damage to [target]'s [IO.name] with [tool_name].</span>" )
				IO.damage = 0
			else
				user.visible_message("<span class='notice'>[user] pokes [target]'s mechanical [IO.name] with [tool_name]...</span>", \
				"<span class='notice'>You poke [target]'s mechanical [IO.name] with [tool_name]... <span class='warning'>For no effect, since it's robotic.</span></span>")

/datum/surgery_step/ribcage/fix_chest_internal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s chest with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s chest with \the [tool]!</span>")
	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)

	else if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			target.adjustToxLoss(7)
		else
			dam_amt = 5
			target.adjustToxLoss(10)
			BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)

	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			IO.take_damage(dam_amt,0)

/datum/surgery_step/ribcage/fix_chest_internal_robot //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)
	allowed_species = null

	min_duration = 70
	max_duration = 90

/datum/surgery_step/ribcage/fix_chest_internal_robot/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	if(target.op_stage.ribcage != 2)
		return FALSE
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.robotic == 2)
			return TRUE
	return FALSE

/datum/surgery_step/ribcage/fix_chest_internal_robot/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.robotic == 2)
			user.visible_message("[user] starts mending the mechanisms on [target]'s [IO] with \the [tool].",
			"You start mending the mechanisms on [target]'s [IO] with \the [tool]." )
			continue
	if(target.species && target.species.flags[NO_PAIN])
		target.custom_pain("You notice slight movement in your chest.",1)
	else
		target.custom_pain("The pain in your chest is a living hell!",1)
	..()

/datum/surgery_step/ribcage/fix_chest_internal_robot/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.robotic == 2)
			user.visible_message("<span class='notice'>[user] repairs [target]'s [IO] with \the [tool].</span>",
			"<span class='notice'>You repair [target]'s [IO] with \the [tool].</span>" )
			IO.damage = 0

/datum/surgery_step/ribcage/fix_chest_internal_robot/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
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

//////////////////////////////////////////////////////////////////
//				EXTRACTING DIONA'S BRAIN						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage/cut_diona_brain
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)
	allowed_species = list(DIONA)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ribcage/cut_diona_brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 2

/datum/surgery_step/ribcage/cut_diona_brain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts separating connections to [target]'s brain with \the [tool].",
	"You start separating connections to [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/ribcage/cut_diona_brain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] separates connections to [target]'s brain with \the [tool].</span>",
	"<span class='notice'>You separate connections to [target]'s brain with \the [tool].</span>")
	target.chest_brain_op_stage = 1

/datum/surgery_step/ribcage/cut_diona_brain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>")
	BP.take_damage(50, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ribcage/cut_diona_spine
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/ribcage/cut_diona_spine/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.chest_brain_op_stage == 1 && target.op_stage.ribcage == 2

/datum/surgery_step/ribcage/cut_diona_spine/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts separating [target]'s brain from \his spine with \the [tool].",
	"You start separating [target]'s brain from spine with \the [tool].")
	..()

/datum/surgery_step/ribcage/cut_diona_spine/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] separates [target]'s brain from \his spine with \the [tool].</span>",
	"<span class='notice'>You separate [target]'s brain from spine with \the [tool].</span>")

	var/mob/living/simple_animal/borer/borer = target.has_brain_worms()

	if(borer)
		borer.detatch()

	target.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")

	target.chest_brain_op_stage = 2.0
	target.death()

/datum/surgery_step/ribcage/cut_diona_spine/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>")
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		H.bloody_body(target)
		H.bloody_hands(target, 0)
//////////////////////////////////////////////////////////////////
//				EXTRACTING IPC'S BRAIN							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ipc_ribcage/cut_posibrain
	allowed_tools = list(
	/obj/item/weapon/wirecutters = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ipc_ribcage/cut_posibrain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 2

/datum/surgery_step/ipc_ribcage/cut_posibrain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting wires connecting [target]'s posi-brain with \the [tool].",
	"You start cutting wires connecting [target]'s posi-brain with \the [tool].")
	..()

/datum/surgery_step/ipc_ribcage/cut_posibrain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts wires connecting [target]'s posi-brain with \the [tool].</span>",
	"<span class='notice'>You cut wires connecting [target]'s posi-brain with \the [tool].</span>")
	target.chest_brain_op_stage = 1

/datum/surgery_step/ipc_ribcage/cut_posibrain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, severely denting [target]'s posi-brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, severely denting [target]'s posi-brain with \the [tool]!</span>")
	BP.take_damage(50, 0, DAM_SHARP, tool)

/datum/surgery_step/ipc_ribcage/extract_posibrain
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)
	priority = 4

	min_duration = 50
	max_duration = 70

/datum/surgery_step/ipc_ribcage/extract_posibrain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.chest_brain_op_stage == 1 && target.op_stage.ribcage == 2

/datum/surgery_step/ipc_ribcage/extract_posibrain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts prying out [target]'s posi-brain from \his hatch with \the [tool].",
	"You start prying out [target]'s posi-brain from hatch with \the [tool].")
	..()

/datum/surgery_step/ipc_ribcage/extract_posibrain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pries out [target]'s posi-brain from \his hatch with \the [tool].</span>",
	"<span class='notice'>You pry out [target]'s posi-brain from hatch with \the [tool].</span>")

	target.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")

	var/obj/item/device/mmi/posibrain/P = new(target.loc)
	P.transfer_identity(target)

	target.chest_brain_op_stage = 2
	target.death()

/datum/surgery_step/ipc_ribcage/extract_posibrain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, severely denting [target]'s posi-brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, severely denting [target]'s posi-brain with \the [tool]!</span>")
	BP.take_damage(30, 0, DAM_SHARP, tool)

/datum/surgery_step/ipc_ribcage/import_posibrain
	allowed_tools = list(
	/obj/item/device/mmi/posibrain = 100
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/ipc_ribcage/import_posibrain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.chest_brain_op_stage == 2 && target.op_stage.ribcage == 2

/datum/surgery_step/ipc_ribcage/import_posibrain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts fiddling in \the [tool] into [target].",
	"Your start fiddling in \the [tool] into [target].")
	..()

/datum/surgery_step/ipc_ribcage/import_posibrain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] fiddled in \the [tool] into [target].</span>",
	"<span class='notice'>You fiddled in \the [tool] into [target].</span>")

	var/obj/item/device/mmi/posibrain/PB = tool
	if(PB.brainmob && PB.brainmob.mind)
		PB.brainmob.mind.transfer_to(target)
		target.dna = PB.brainmob.dna

	qdel(tool)
//////////////////////////////////////////////////////////////////
//				RIBCAGE	ROBOTIC SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ipc_ribcage
	can_infect = FALSE
	priority = 2
	allowed_species = list(IPC)

/datum/surgery_step/ipc_ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	return target_zone == BP_CHEST

/datum/surgery_step/ipc_ribcage/wrench_sec
	allowed_tools = list(
	/obj/item/weapon/wrench = 100,
	/obj/item/weapon/bonesetter = 75
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/ipc_ribcage/wrench_sec/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return target.op_stage.ribcage == 0 && BP.open >= 2

/datum/surgery_step/ipc_ribcage/wrench_sec/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to loosen bolts on [target]'s security panel with \the [tool].",
	"You begin to loosen bolts on [target]'s maintenance panel with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "%MAIN SECURITY PANEL% UNATHORISED ACCESS ATTEMPT DETECTED!")
	..()

/datum/surgery_step/ipc_ribcage/wrench_sec/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'> [user] has loosen bolts on [target]'s security panel with \the [tool].</span>",
	"<span class='notice'> You have loosen bolts on [target]'s security panel with \the [tool].</span>")
	target.op_stage.ribcage = 1

/datum/surgery_step/ipc_ribcage/wrench_sec/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s security panel with \the [tool]!</span>" ,
	"<span class='warning'>Your hand slips, scratching [target]'s security panel with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc_ribcage/pry_sec
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)
	priority = 3

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ipc_ribcage/pry_sec/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 1

/datum/surgery_step/ipc_ribcage/pry_sec/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to pry open the security panel in [target]'s torso with \the [tool].",
	"You start to pry open the security panel in [target]'s torso with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "<span class='warning italics'>%MAIN SECURITY PANEL% DAMAGE DETECTED. CEASE APPLIED DAMAGE.</span>")
	..()

/datum/surgery_step/ipc_ribcage/pry_sec/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class = 'notice'>[user] pries open [target]'s security panel with \the [tool].</span>"
	var/self_msg = "<span class = 'notice'> You force open [target]'s ribcage with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	target.op_stage.ribcage = 2
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.open = 3

/datum/surgery_step/ipc_ribcage/pry_sec/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, breaking [target]'s security panel!</span>",
	"<span class='warning'>Your hand slips, breaking [target]'s security panel!</span>")
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, used_weapon = tool)

/datum/surgery_step/ipc_ribcage/shut_sec
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/ipc_ribcage/shut_sec/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 2

/datum/surgery_step/ipc_ribcage/shut_sec/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts prying [target]'s security panel back into place with \the [tool].", "You start prying [target]'s securty panel back into place with \the [tool].")
	..()

/datum/surgery_step/ipc_ribcage/shut_sec/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class = 'notice'>[user] pry [target]'s security panel back into place with \the [tool].</span>"
	var/self_msg = "<span class = 'notice'>You pry [target]'s security panel back into place with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	target.op_stage.ribcage = 1
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.open = 2

/datum/surgery_step/ipc_ribcage/shut_sec/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "<span class='warning'>[user]'s hand slips, bending [target]'s security panel the wrong way!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, bending [target]'s security panel the wrong way!</span>"
	user.visible_message(msg, self_msg)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	BP.fracture()
	BP.take_damage(20, 0, used_weapon = tool)
	if(prob(40))
		user.visible_message("<span class='warning'>A loud bang can be heard.</span>")
		target.rupture_lung()

/datum/surgery_step/ipc_ribcage/wrenchshut_sec
	allowed_tools = list(
	/obj/item/weapon/wrench = 100,
	/obj/item/weapon/bonesetter = 75
	)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/ipc_ribcage/wrenchshut_sec/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.ribcage == 1

/datum/surgery_step/ipc_ribcage/wrenchshut_sec/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts tighetning bolts on [target]'s security panel with \the [tool].", "You start tighetning bolts on [target]'s security panel with \the [tool].")
	..()

/datum/surgery_step/ipc_ribcage/wrenchshut_sec/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'> [user] has loosen bolts on [target]'s security panel with \the [tool].</span>",
	"<span class='notice'> You have loosen bolts on [target]'s security panel with \the [tool].</span>")

	target.op_stage.ribcage = 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.open = 1

/datum/surgery_step/ipc_ribcage/wrenchshut_sec/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s security panel with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s security panel with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc_ribcage/take_accumulator
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/ipc_ribcage/take_accumulator/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER] // IPC's liver, as of now is an accumulator.
	if(!locate(/obj/item/weapon/stock_parts/cell) in accum)
		return FALSE
	return target.op_stage.ribcage == 2

/datum/surgery_step/ipc_ribcage/take_accumulator/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to unscrew [target]'s accumulator out with \the [tool].",
	"You start unscrewing [target]'s accumulator with \the [tool].")
	..()

/datum/surgery_step/ipc_ribcage/take_accumulator/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] unscrewed [target]'s accumulator with \the [tool].</span>",
	"<span class='notice'>You unscrewed [target]'s accumulator with \the [tool].</span>")
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER]
	var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in accum
	C.forceMove(get_turf(target))
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "<span class='warning italics'>%SHUTTING DOWN%</span>")

/datum/surgery_step/ipc_ribcage/take_accumulator/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s accumulator with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s accumulator with \the [tool]!</span>")
	var/obj/item/organ/internal/liver/ipc/A = target.organs_by_name[O_LIVER]
	A.damage += 10
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc_ribcage/put_accumulator
	allowed_tools = list(
	/obj/item/weapon/stock_parts/cell = 100
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/ipc_ribcage/put_accumulator/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER] // IPC's liver, as of now is an accumulator.
	if(locate(/obj/item/weapon/stock_parts/cell) in accum)
		return
	return target.op_stage.ribcage == 2

/datum/surgery_step/ipc_ribcage/put_accumulator/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts putting in \the [tool] into [target]'s accumulator slot.",
	"You start putting in \the [tool] into [target]'s accumulator slot.")
	..()

/datum/surgery_step/ipc_ribcage/put_accumulator/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has put in \the [tool] into [target]'s accumulator slot.</span>",
	"<span class='notice'>You have put in \the [tool] into [target]'s accumulator slot.</span>")

	user.drop_item()
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER]
	tool.forceMove(accum)

	var/obj/item/weapon/stock_parts/cell/C = tool

	if (target.nutrition > C.maxcharge)
		target.nutrition = C.maxcharge