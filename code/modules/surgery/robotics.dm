//Procedures in this file: Robotic surgery steps, organ removal, replacement. MMI insertion, synthetic organ repair.
//////////////////////////////////////////////////////////////////
//						ROBOTIC SURGERY							//
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//	generic robotic surgery step datum
//////////////////////////////////////////////////////////////////

/datum/surgery_step/robotics
	can_infect = 0

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(isslime(target))
		return 0
	if(target_zone == BP_EYES)	//there are specific steps for eye surgery
		return 0
	if(!ishuman(target))
		return 0

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!BP)
		return 0
	if(!(BP.status & ORGAN_ROBOT))
		return 0
	if(BP.is_stump())
		return 0
	if(BP.status & ORGAN_CUT_AWAY)
		return 0

	return 1

//////////////////////////////////////////////////////////////////
//	 unscrew robotic limb hatch surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/unscrew_hatch
	allowed_tools = list(
		 /obj/item/weapon/screwdriver = 100
		,/obj/item/weapon/coin = 50
		,/obj/item/weapon/kitchen/utensil/knife = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/robotics/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && BP.open == 0 && target_zone != BP_MOUTH

/datum/surgery_step/robotics/unscrew_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [BP.name] with \the [tool].",
		                     "You start to unscrew the maintenance hatch on [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has opened the maintenance hatch on [target]'s [BP.name] with \the [tool].</span>",
		                   "<span class='notice'>You have opened the maintenance hatch on [target]'s [BP.name] with \the [tool].</span>")
	BP.open = 1

/datum/surgery_step/robotics/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to unscrew [target]'s [BP.name].</span>",
		                          "<span class='warning'>Your [tool] slips, failing to unscrew [target]'s [BP.name].</span>")

//////////////////////////////////////////////////////////////////
//	open robotic limb surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/open_hatch
	allowed_tools = list(
		 /obj/item/weapon/retractor = 100
		,/obj/item/weapon/crowbar = 100
		,/obj/item/weapon/kitchen/utensil = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/robotics/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && BP.open == 1

/datum/surgery_step/robotics/open_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [BP.name] with \the [tool].",
		                     "You start to pry open the maintenance hatch on [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] opens the maintenance hatch on [target]'s [BP.name] with \the [tool].</span>",
		                     "<span class='notice'>You open the maintenance hatch on [target]'s [BP.name] with \the [tool].</span>")
	BP.open = 3

/datum/surgery_step/robotics/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to open the hatch on [target]'s [BP.name].</span>",
		                          "<span class='warning'>Your [tool] slips, failing to open the hatch on [target]'s [BP.name].</span>")

//////////////////////////////////////////////////////////////////
//	close robotic limb surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/close_hatch
	allowed_tools = list(
		 /obj/item/weapon/retractor = 100
		,/obj/item/weapon/crowbar = 100
		,/obj/item/weapon/kitchen/utensil = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/robotics/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && BP.open && target_zone != BP_MOUTH

/datum/surgery_step/robotics/close_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [BP.name] with \the [tool].",
		                     "You begin to close and secure the hatch on [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] closes and secures the hatch on [target]'s [BP.name] with \the [tool].</span>",
		                      "<span class='notice'>You close and secure the hatch on [target]'s [BP.name] with \the [tool].</span>")
	BP.open = 0
	BP.germ_level = 0

/datum/surgery_step/robotics/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to close the hatch on [target]'s [BP.name].</span>",
		                     "<span class='warning'>Your [tool.name] slips, failing to close the hatch on [target]'s [BP.name].</span>")

//////////////////////////////////////////////////////////////////
//	robotic limb brute damage repair surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/repair_brute
	allowed_tools = list(
		/obj/item/weapon/weldingtool = 100
		,/obj/item/weapon/pickaxe/plasmacutter = 50
	)

	min_duration = 50
	max_duration = 60

/datum/surgery_step/robotics/repair_brute/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(istype(tool,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = tool
		if(!welder.isOn() || !welder.remove_fuel(1,user))
			return 0
	return BP && BP.open == 3 && (BP.disfigured || BP.brute_dam > 0) && target_zone != BP_MOUTH

/datum/surgery_step/robotics/repair_brute/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] begins to patch damage to [target]'s [BP.name]'s support structure with \the [tool].",
		                     "You begin to patch damage to [target]'s [BP.name]'s support structure with \the [tool].")
	..()

/datum/surgery_step/robotics/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] finishes patching damage to [target]'s [BP.name] with \the [tool].</span>",
		                      "<span class='notice'>You finish patching damage to [target]'s [BP.name] with \the [tool].</span>")
	BP.heal_damage(rand(30,50),0,1,1)
	BP.disfigured = 0

/datum/surgery_step/robotics/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, damaging the internal structure of [target]'s [BP.name].</span>",
		                     "<span class='warning'>Your [tool.name] slips, damaging the internal structure of [target]'s [BP.name].</span>")
	target.apply_damage(rand(5,10), BURN, BP)

//////////////////////////////////////////////////////////////////
//	robotic limb burn damage repair surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/repair_burn
	allowed_tools = list(
		/obj/item/weapon/cable_coil = 100
	)

	min_duration = 50
	max_duration = 60

/datum/surgery_step/robotics/repair_burn/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/weapon/cable_coil/C = tool
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	var/limb_can_operate = ((BP && BP.open >= 3) && (BP.disfigured || BP.burn_dam > 0) && target_zone != BP_MOUTH)
	if(limb_can_operate)
		if(istype(C))
			if(!C.use(3))
				to_chat(user, "<span class='danger'>You need three or more cable pieces to repair this damage.</span>")
				return SURGERY_FAILURE
			return 1
	return SURGERY_FAILURE

	if(!limb_can_operate)
		return 0

	if(istype(C))
		if(!C.use(10))
			to_chat(user, "<span class='danger'>You need ten or more cable pieces to repair this damage.</span>")//usage amount made more consistent with regular cable repair
			return SURGERY_FAILURE
	return 1

/datum/surgery_step/robotics/repair_burn/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] begins to splice new cabling into [target]'s [BP.name].",
		                     "You begin to splice new cabling into [target]'s [BP.name].")
	..()

/datum/surgery_step/robotics/repair_burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] finishes splicing cable into [target]'s [BP.name].</span>",
		                "<span class='notice'>You finishes splicing new cable into [target]'s [BP.name].</span>")
	BP.heal_damage(0,rand(30,50),1,1)
	BP.disfigured = 0

/datum/surgery_step/robotics/repair_burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user] causes a short circuit in [target]'s [BP.name]!</span>",
		                     "<span class='warning'>You cause a short circuit in [target]'s [BP.name]!</span>")
	target.apply_damage(rand(5,10), BURN, BP)

//////////////////////////////////////////////////////////////////
//	 artificial organ repair surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/fix_organ_robotic //For artificial organs
	allowed_tools = list(
		 /obj/item/stack/nanopaste = 100
		,/obj/item/weapon/bonegel = 30
		,/obj/item/weapon/screwdriver = 70
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/robotics/fix_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasbodyparts(target))
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!BP)
		return
	var/is_organ_damaged = 0
	for(var/obj/item/organ/IO in BP.organs)
		if(IO.damage > 0 && (IO.robotic >= 2))
			is_organ_damaged = 1
			break
	return BP.open == 3 && is_organ_damaged

/datum/surgery_step/robotics/fix_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasbodyparts(target))
		return
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	for(var/obj/item/organ/IO in BP.organs)
		if(IO && IO.damage > 0)
			if(IO.robotic >= 2)
				user.visible_message("[user] starts mending the damage to [target]'s [IO.name]'s mechanisms.",
					                     "You start mending the damage to [target]'s [IO.name]'s mechanisms.")
	..()

/datum/surgery_step/robotics/fix_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasbodyparts(target))
		return
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	for(var/obj/item/organ/IO in BP.organs)

		if(IO && IO.damage > 0)
			if(IO.robotic >= 2)
				user.visible_message("<span class='notice'>[user] repairs [target]'s [IO.name] with [tool].</span>",
					                     "<span class='notice'>You repair [target]'s [IO.name] with [tool].</span>")
				IO.damage = 0

/datum/surgery_step/robotics/fix_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasbodyparts(target))
		return
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [BP.name] with \the [tool]!</span>",
		                     "<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [BP.name] with \the [tool]!</span>")

	target.adjustToxLoss(5)
	BP.createwound(CUT, 5)

	for(var/obj/item/organ/IO in BP.organs)
		if(IO)
			IO.take_damage(rand(3,5),0)

//////////////////////////////////////////////////////////////////
//	robotic organ detachment surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/detatch_organ_robotic // :D

	allowed_tools = list(
		/obj/item/device/multitool = 100
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/robotics/detatch_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!(BP && (BP.status & ORGAN_ROBOT)))
		return 0
	if(BP.open < 3)
		return 0

	target.op_stage.current_organ = null

	var/list/attached_organs = list()
	for(var/organ in target.organs_by_name)
		var/obj/item/organ/IO = target.organs_by_name[organ]
		if(IO && !(IO.status & ORGAN_CUT_AWAY) && IO.parent_bodypart == target_zone)
			attached_organs += organ

	var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove

	return ..() && organ_to_remove

/datum/surgery_step/robotics/detatch_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to decouple [target]'s [target.op_stage.current_organ] with \the [tool].",
		                     "You start to decouple [target]'s [target.op_stage.current_organ] with \the [tool].")
	..()

/datum/surgery_step/robotics/detatch_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has decoupled [target]'s [target.op_stage.current_organ] with \the [tool].</span>",
		                   "<span class='notice'>You have decoupled [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/IO = target.organs_by_name[target.op_stage.current_organ]
	if(IO && istype(IO))
		var/obj/item/bodypart/BP = target.get_bodypart(IO.parent_bodypart)
		IO.removed(user, TRUE, FALSE)
		BP.implants += IO

/datum/surgery_step/robotics/detatch_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting \the [tool].</span>",
	"<span class='warning'>Your hand slips, disconnecting \the [tool].</span>")

//////////////////////////////////////////////////////////////////
//	robotic organ removal surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/remove_organ_robotic

	allowed_tools = list(
		 /obj/item/weapon/hemostat = 100
		,/obj/item/weapon/wirecutters = 75
		,/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!..())
		return 0

	target.op_stage.current_organ = null

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!BP)
		return 0

	if(!(BP && (BP.status & ORGAN_ROBOT)))
		return 0

	var/list/removable_organs = list()
	for(var/obj/item/organ/IO in BP.implants)
		if(IO.status & ORGAN_CUT_AWAY)
			removable_organs += IO

	var/organ_to_remove = input(user, "Which organ do you want to remove?") as null|anything in removable_organs
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove
	return ..()

/datum/surgery_step/internal/remove_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts removing [target]'s [target.op_stage.current_organ] with \the [tool].",
		                     "You start removing [target]'s [target.op_stage.current_organ] with \the [tool].")
	..()

/datum/surgery_step/internal/remove_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>",
		                   "<span class='notice'>You have removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	// Extract the organ!
	var/obj/item/organ/IO = target.op_stage.current_organ
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(istype(IO) && istype(BP))
		BP.implants -= IO
		user.put_in_hands(IO.extracted())
		target.op_stage.current_organ = null
		playsound(target.loc, 'sound/items/Ratchet.ogg', 50, 1)

	//if(istype(IO, /obj/item/organ/internal/mmi_holder))
	//	var/obj/item/organ/internal/mmi_holder/brain = IO
	//	brain.transfer_and_delete()

/datum/surgery_step/internal/remove_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>",
		                     "<span class='warning'>Your hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>")
	BP.createwound(BRUISE, 20)

//////////////////////////////////////////////////////////////////
//	robotic organ transplant finalization surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/attach_organ_robotic
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100
	)

	min_duration = 100
	max_duration = 120

/datum/surgery_step/robotics/attach_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!(BP && (BP.status & ORGAN_ROBOT)))
		return 0
	if(BP.open < 3)
		return 0

	target.op_stage.current_organ = null

	var/list/removable_organs = list()
	for(var/obj/item/organ/IO in BP.implants)
		if ((IO.status & ORGAN_CUT_AWAY) && (IO.robotic >= 2) && (IO.parent_bodypart == target_zone))
			removable_organs += IO

	var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
	if(!organ_to_replace)
		return 0

	target.op_stage.current_organ = organ_to_replace
	return ..()

/datum/surgery_step/robotics/attach_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].",
		                     "You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
	..()

/datum/surgery_step/robotics/attach_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>",
		                   "<span class='notice'>You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/IO = target.op_stage.current_organ
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(istype(IO) && IO.parent_bodypart == target_zone && BP && (IO in BP.implants))
		IO.status &= ~ORGAN_CUT_AWAY
		BP.implants -= IO
		IO.inserted(target)
		target.op_stage.current_organ = null

/datum/surgery_step/robotics/attach_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting \the [tool].</span>",
		                     "<span class='warning'>Your hand slips, disconnecting \the [tool].</span>")

//////////////////////////////////////////////////////////////////
//	mmi installation surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotics/install_mmi
	allowed_tools = list(
		/obj/item/device/mmi/posibrain = 100
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/robotics/install_mmi/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(target_zone != BP_CHEST)
		return

	var/obj/item/device/mmi/posibrain/M = tool
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!(BP && BP.open == 3))
		return 0

	if(!istype(M))
		return 0

	if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
		to_chat(user, "<span class='danger'>That brain is not usable.</span>")
		return SURGERY_FAILURE

	if(!(BP.status & ORGAN_ROBOT))
		to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat torso.</span>")
		return SURGERY_FAILURE

	if(!target.should_have_organ(BP_BRAIN))
		to_chat(user, "<span class='danger'>You're pretty sure [lowertext(target.species.name)]s don't normally have a brain.</span>")
		return SURGERY_FAILURE

	if(!isnull(target.organs[BP_BRAIN]))
		to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
		return SURGERY_FAILURE

	return 1

/datum/surgery_step/robotics/install_mmi/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts installing \the [tool] into [target]'s [BP.name].",
		                     "You start installing \the [tool] into [target]'s [BP.name].")
	..()

/datum/surgery_step/robotics/install_mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has installed \the [tool] into [target]'s [BP.name].</span>",
		                   "<span class='notice'>You have installed \the [tool] into [target]'s [BP.name].</span>")

	var/obj/item/device/mmi/posibrain/MMI = tool
	if(MMI.brain_item)
		user.transferItemToLoc(MMI, MMI.brain_item)
		MMI.brain_item.status &= ~ORGAN_CUT_AWAY
		MMI.brain_item.posibrain = MMI
		MMI.brain_item.inserted(target)
	else
		var/obj/item/organ/brain/mmi_holder/holder = new (null, target, MMI)
		user.transferItemToLoc(MMI, holder)

		//MMI.brain_mob.container = holder
		//MMI.brain_mob.robot_talk_understand = FALSE

		//holder.brain_mob = MMI.brain_mob
		//holder.posi = MMI

		//MMI.brain_mob = null

		//holder.inserted(target)
		//MMI.holder = null


	//qdel(MMI)

	//var/obj/item/organ/internal/mmi_holder/holder = new(target, 1)
	//target.organs_by_name[BP_BRAIN] = holder
	//user.drop_from_inventory(tool)
	//tool.forceMove(holder)
	//holder.stored_mmi = tool
	//holder.update_from_mmi()

	//if(MMI.brainmob && MMI.brainmob.mind)
	//	MMI.brainmob.mind.transfer_to(target)

/datum/surgery_step/robotics/install_mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips.</span>",
		                     "<span class='warning'>Your hand slips.</span>")
