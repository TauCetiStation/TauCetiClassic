//Procedures in this file: internal organ surgery, removal, transplants
//////////////////////////////////////////////////////////////////
//						INTERNAL ORGANS							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && BP.open == (BP.encased ? 3 : 2)

//////////////////////////////////////////////////////////////////
//	Organ mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
		 /obj/item/stack/medical/advanced/bruise_pack= 100
		,/obj/item/stack/medical/bruise_pack = 40
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/internal/fix_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	for(var/obj/item/organ/IO in BP.organs)
		if(IO.damage > 0)
			if(IO.surface_accessible)
				return TRUE
			if(BP.open >= (BP.encased ? 3 : 2))
				return TRUE
	return FALSE

/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	for(var/obj/item/organ/IO in BP.organs)
		if(IO && IO.damage > 0 && IO.robotic < 2 && (IO.surface_accessible || BP.open >= (BP.encased ? 3 : 2)))
			user.visible_message("[user] starts treating damage to [target]'s [IO.name] with [tool_name].",
				                     "You start treating damage to [target]'s [IO.name] with [tool_name]." )

	target.custom_pain("The pain in your [BP.name] is living hell!", 100, BP = BP)
	..()

/datum/surgery_step/internal/fix_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	for(var/obj/item/organ/IO in BP.organs)
		if(IO && IO.damage > 0 && IO.robotic < 2 && (IO.surface_accessible || BP.open >= (BP.encased ? 3 : 2)))
			user.visible_message("<span class='notice'>[user] treats damage to [target]'s [IO.name] with [tool_name].</span>",
				                     "<span class='notice'>You treat damage to [target]'s [IO.name] with [tool_name].</span>" )
			IO.damage = 0

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s [BP.name] with \the [tool]!</span>",
		                     "<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s [BP.name] with \the [tool]!</span>")

	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)
	else
		dam_amt = 5
		target.adjustToxLoss(10)
		BP.take_damage(dam_amt, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

	for(var/obj/item/organ/IO in BP.organs)
		if(IO && IO.damage > 0 && IO.robotic < 2 && (IO.surface_accessible || BP.open >= (BP.encased ? 3 : 2)))
			IO.take_damage(dam_amt, 0)

//////////////////////////////////////////////////////////////////
// Organ detatchment surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/detatch_organ // :D
	allowed_tools = list(
		 /obj/item/weapon/scalpel = 100
		,/obj/item/weapon/kitchen/utensil/knife = 75
		,/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/internal/detatch_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	if(!(BP && !(BP.status & ORGAN_ROBOT)))
		return 0

	target.op_stage.current_organ = null

	var/list/attached_organs = list()
	for(var/organ in target.organs_by_name)
		var/obj/item/organ/IO = target.organs_by_name[organ]
		if(IO && !(IO.status & ORGAN_CUT_AWAY) && IO.parent_bodypart == target_zone)
			attached_organs += organ

	var/organ_to_remove = input(user, "Which organ do you want to separate?") as null|anything in attached_organs
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove

	return ..() && organ_to_remove

/datum/surgery_step/internal/detatch_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to separate [target]'s [target.op_stage.current_organ] with \the [tool].",
		                     "You start to separate [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("Someone's ripping out your [target.op_stage.current_organ]!", 100)
	..()

/datum/surgery_step/internal/detatch_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has separated [target]'s [target.op_stage.current_organ] with \the [tool].</span>",
		                   "<span class='notice'>You have separated [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/IO = target.organs_by_name[target.op_stage.current_organ]
	if(IO && istype(IO))
		var/obj/item/bodypart/BP = target.get_bodypart(IO.parent_bodypart)
		IO.removed(user, TRUE, FALSE)
		BP.implants += IO

/datum/surgery_step/internal/detatch_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s [BP.name] with \the [tool]!</span>",
		                     "<span class='warning'>Your hand slips, slicing an artery inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(rand(30,50), 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 Organ removal surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/remove_organ
	allowed_tools = list(
		 /obj/item/weapon/hemostat = 100,
		,/obj/item/weapon/wirecutters = 75,
		,/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0

	target.op_stage.current_organ = null

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!(BP && !(BP.status & ORGAN_ROBOT)))
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

/datum/surgery_step/internal/remove_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts removing [target]'s [target.op_stage.current_organ] with \the [tool].", \
		                     "You start removing [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is living hell!", 100, BP = BP)
	..()

/datum/surgery_step/internal/remove_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>", \
		                   "<span class='notice'>You have removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	// Extract the organ!
	var/obj/item/organ/IO = target.op_stage.current_organ
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(istype(IO) && istype(BP))
		BP.implants -= IO
		user.put_in_hands(IO)
		target.op_stage.current_organ = null
		playsound(target, 'sound/effects/squelch1.ogg', 50, 1)

	// Just in case somehow the organ we're extracting from an organic is an MMI
	//if(istype(IO, /obj/item/organ/internal/mmi_holder))
	//	var/obj/item/organ/internal/mmi_holder/brain = IO
	//	brain.transfer_and_delete()

/datum/surgery_step/internal/remove_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>", \
		                     "<span class='warning'>Your hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 Organ inserting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/replace_organ
	allowed_tools = list(
		/obj/item/organ = 100
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/replace_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return

	var/obj/item/organ/IO = tool
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)

	var/organ_compatible
	var/organ_missing

	if(!istype(IO))
		return 0

	if((BP.status & ORGAN_ROBOT) && !(IO.robotic >= 2))
		to_chat(user, "<span class='danger'>You cannot install a naked organ into a robotic body.</span>")
		return SURGERY_FAILURE

	if(!target.species)
		CRASH("Target ([target]) of surgery [src.type] has no species!")
		return SURGERY_FAILURE

	var/o_is = (IO.gender == PLURAL) ? "are" : "is"
	var/o_a =  (IO.gender == PLURAL) ? "" : "a "
	var/o_do = (IO.gender == PLURAL) ? "don't" : "doesn't"

	if(IO.damage > (IO.max_damage * 0.75))
		to_chat(user, "<span class='warning'>\The [IO.organ_tag] [o_is] in no state to be transplanted.</span>")
		return SURGERY_FAILURE

	if(!target.organs_by_name[IO.organ_tag])
		organ_missing = 1
	else
		to_chat(user, "<span class='warning'>\The [target] already has [o_a][IO.organ_tag].</span>")
		return SURGERY_FAILURE

	if(IO && BP.body_zone == IO.parent_bodypart)
		organ_compatible = 1
	//else if(istype(IO, /obj/item/organ/stack))
	//	if(!target.organs_by_name[IO.organ_tag])
	//		organ_missing = 1
	//	else
	//		to_chat(user, "<span class='warning'>\The [target] already has [o_a][IO.organ_tag].</span>")
	//		return SURGERY_FAILURE
	else
		to_chat(user, "<span class='warning'>\The [IO.organ_tag] [o_do] normally go in \the [BP.name].</span>")
		return SURGERY_FAILURE

	return organ_missing && organ_compatible

/datum/surgery_step/internal/replace_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [BP.name].", \
		                     "You start transplanting \the [tool] into [target]'s [BP.name].")
	target.custom_pain("Someone's rooting around in your [BP.name]!", 100, BP = BP)
	..()

/datum/surgery_step/internal/replace_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has transplanted \the [tool] into [target]'s [BP.name].</span>", \
		                   "<span class='notice'>You have transplanted \the [tool] into [target]'s [BP.name].</span>")
	var/obj/item/organ/IO = tool
	if(istype(IO))
		user.transferItemToLoc(IO, target)
		BP.implants += IO // move the organ into the patient. The organ is properly reattached in the next step
		if(!(IO.status & ORGAN_CUT_AWAY))
			message_admins("[user] ([user.ckey]) replaced organ [IO], which didn't have ORGAN_CUT_AWAY set, in [target] ([target.ckey])")
			IO.status |= ORGAN_CUT_AWAY

		playsound(target, 'sound/effects/squelch1.ogg', 50, 1)

/datum/surgery_step/internal/replace_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging \the [tool]!</span>")
	var/obj/item/organ/IO = tool
	if(istype(IO))
		IO.take_damage(rand(3,5),0)

//////////////////////////////////////////////////////////////////
//	 Organ inserting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/attach_organ
	allowed_tools = list(
		 /obj/item/weapon/FixOVein = 100
		,/obj/item/weapon/cable_coil = 75
	)

	min_duration = 100
	max_duration = 120

/datum/surgery_step/internal/attach_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0

	target.op_stage.current_organ = null

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(BP.status & ORGAN_ROBOT)
		// robotic attachment handled via screwdriver
		return 0

	var/list/attachable_organs = list()
	for(var/obj/item/organ/IO in BP.implants)
		if(IO && (IO.status & ORGAN_CUT_AWAY) && IO.parent_bodypart == target_zone)
			attachable_organs += IO

	var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in attachable_organs
	if(!organ_to_replace)
		return 0

	target.op_stage.current_organ = organ_to_replace
	return ..()

/datum/surgery_step/internal/attach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].",
		                     "You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("Someone's digging needles into your [target.op_stage.current_organ]!", 100)
	..()

/datum/surgery_step/internal/attach_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>",
		                   "<span class='notice'>You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/IO = target.op_stage.current_organ
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(istype(IO) && IO.parent_bodypart == target_zone && BP && (IO in BP.implants))
		IO.status &= ~ORGAN_CUT_AWAY // apply fixovein
		BP.implants -= IO
		IO.inserted(target)
		target.op_stage.current_organ = null

/datum/surgery_step/internal/attach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the flesh in [target]'s [BP.name] with \the [tool]!</span>", \
		                     "<span class='warning'>Your hand slips, damaging the flesh in [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, used_weapon = tool)
