//////////////////////////////////////////////////////////////////
//				EYE SURGERY manipulation for eyes				//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/organ_manipulation/place_eye
	priority = 2
	allowed_tools = list(/obj/item/organ/internal/eyes = 100)

	allowed_species = list("exclude", IPC, DIONA)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/organ_manipulation/place_eye/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
    if(!ishuman(target))
        return FALSE

    if(target_zone != O_EYES)
        return FALSE


    var/obj/item/organ/internal/I = tool
    if(I.requires_robotic_bodypart)
        user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
        return FALSE

    if(I.damage > (I.max_damage * 0.75))
        user.visible_message ( "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
        return FALSE

    if(target.get_int_organ(I))
        user.visible_message ( "<span class='warning'> \The [target] already has [I].</span>")
        return FALSE

    return TRUE


/datum/surgery_step/organ_manipulation/place_eye/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
		"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")
	..()

/datum/surgery_step/organ_manipulation/place_eye/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/I = tool
	user.drop_from_inventory(tool)
	I.insert_organ(target)
	user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target].</span>", \
	"<span class='notice'> You have transplanted \the [tool] into [target].</span>")
	I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/organ_manipulation/place_eye/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
