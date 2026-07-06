//Procedures in this file: Damage repair surgery
//////////////////////////////////////////////////////////////////
//						TISSUE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/add_tissue
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack = 100,
	/obj/item/stack/medical/advanced/ointment = 100
	)

	blood_level = 1

	min_duration = 50
	max_duration = 60


/datum/surgery_step/add_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	if(!ishuman(target))
		return FALSE

	if(tool.amount == 0)
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(!(BP.brute_dam > 20 || BP.burn_dam > 20))
		return FALSE

	return BP && BP.open >= 2 && BP.stage == 0

/datum/surgery_step/add_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.stage == 0)
		user.visible_message("<span class='notice'>[user] starts adding regenerative membrane to [target]'s [BP.name].</span>", \
		"<span class='notice'>You start adding regenerative membrane to [target]'s [BP.name].</span>")
	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/add_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		BP.trauma_kit = TRUE
	else if(istype(tool, /obj/item/stack/medical/advanced/ointment))
		BP.burn_kit = TRUE
	user.visible_message("<span class='notice'>[user] finishes  adding regenerative membrane to [target]'s [BP.name].</span>", \
		"<span class='notice'>You finish adding regenerative membrane to [target]'s [BP.name].</span>")
	tool.use(1)
	tool.update_icon()
	BP.stage = 3

/datum/surgery_step/add_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>")
	tool.use(1)
	tool.update_icon()


