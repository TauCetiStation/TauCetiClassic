//Procedures in this file: Damage repair surgery
//////////////////////////////////////////////////////////////////
//						TISSUE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/add_tissue
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,
	/obj/item/stack/medical/advanced/ointment= 100
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60


/datum/surgery_step/add_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	if(!ishuman(target))
		return 0

	if(tool.amount == 0)
		return 0

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(BP.brute_dam <= 20 || BP.burn_dam <= 20)
		return 0

	return BP && BP.open >= 2 && BP.stage == 0

/datum/surgery_step/add_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.stage == 0)
		user.visible_message("[user] starts applying medication to the damaged tissue in [target]'s [BP.name] with \the [tool]." , \
		"You start applying medication to the damaged tissue in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/add_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		BP.trauma_kit = TRUE
	else if(istype(tool, /obj/item/stack/medical/advanced/ointment))
		BP.burn_kit = TRUE
	user.visible_message("<span class='notice'>[user] applies some [tool] to [target]'s tissue in [BP.name]</span>", \
		"<span class='notice'>You apply some [tool] to [target]'s tissue in [BP.name] with \the [tool].</span>")
	tool.amount -= 1
	BP.stage = 3

/datum/surgery_step/add_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")
	tool.amount -= 1

/datum/surgery_step/set_tissue
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,
	/obj/item/weapon/wirecutters = 75,
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/set_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	return BP && BP.open >= 2 && BP.stage == 3

/datum/surgery_step/set_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.stage == 3)
		user.visible_message("[user] is beginning to set the tissue in [target]'s [BP.name] in place with \the [tool]." , \
			"You are beginning to set the tissue in [target]'s [BP.name] in place with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is going to make you pass out!",1)
	..()

/datum/surgery_step/set_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] sets the tissue in [target]'s [BP.name] in place with \the [tool].</span>", \
		"<span class='notice'>You set the tissue in [target]'s [BP.name] in place with \the [tool].</span>")
	if(BP.trauma_kit)
		BP.heal_damage(20, 0)
		BP.trauma_kit = FALSE
	if(BP.burn_kit)
		BP.burn_kit = FALSE
		BP.heal_damage(0, 20)
	target.updatehealth()
	BP.stage = 0

/datum/surgery_step/set_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, ripping the tissue in [target]'s [BP.name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, ripping the tissue in [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)
