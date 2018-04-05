//Procedures in this file: Inernal wound patching, Implant removal.
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
	user.visible_message("\blue [user] has patched the damaged vein in [target]'s [BP.name] with \the [tool].", \
		"\blue You have patched the damaged vein in [target]'s [BP.name] with \the [tool].")

	BP.status &= ~ORGAN_ARTERY_CUT
	if (ishuman(user) && prob(40))
		var/mob/living/carbon/human/H = user
		H.bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!" , \
	"\red Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!")
	BP.take_damage(5, 0)
