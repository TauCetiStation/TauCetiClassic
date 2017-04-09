//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//	 Tendon fix surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/fix_tendon
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/weapon/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_tendon/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasbodyparts(target))
		return 0

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && (BP.status & ORGAN_TENDON_CUT) && BP.open >= 2

/datum/surgery_step/fix_tendon/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts reattaching the damaged [BP.tendon_name] in [target]'s [BP.name] with \the [tool]." , \
	"You start reattaching the damaged [BP.tendon_name] in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is unbearable!",100,BP = BP)
	..()

/datum/surgery_step/fix_tendon/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has reattached the [BP.tendon_name] in [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You have reattached the [BP.tendon_name] in [target]'s [BP.name] with \the [tool].</span>")
	BP.status &= ~ORGAN_TENDON_CUT
	BP.update_damages()

/datum/surgery_step/fix_tendon/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")
	BP.take_damage(5, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 IB (artery) fix surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/fix_vein
	priority = 3
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/weapon/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasbodyparts(target))
		return 0

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP && (BP.status & ORGAN_ARTERY_CUT) && BP.open >= 2

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [BP.name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is unbearable!",100,BP = BP)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has patched the damaged vein in [target]'s [BP.name] with \the [tool].", \
		"\blue You have patched the damaged vein in [target]'s [BP.name] with \the [tool].")

	BP.status &= ~ORGAN_ARTERY_CUT
	if (ishuman(user) && prob(40))
		user:bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!" , \
	"\red Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!")
	BP.take_damage(5, 0)
