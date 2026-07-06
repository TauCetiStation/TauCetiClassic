//Procedures in this file: Eye mending surgery
//////////////////////////////////////////////////////////////////
//						EYE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/eye/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/eye/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision around [target]'s eyes with \the [tool]." , \
	"You are beginning to cauterize the incision around [target]'s eyes with \the [tool].")

/datum/surgery_step/eye/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cauterizes the incision around [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision around [target]'s eyes with \the [tool].</span>")
	target.op_stage.eyes = 0

/datum/surgery_step/eye/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips,  searing [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, searing [target]'s eyes with \the [tool]!</span>")
	BP.take_damage(0, 5, used_weapon = tool)
	IO.take_damage(5, 0)


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

//////////////////////////////////////////////////////////////////
//						ROBO EYE SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc/eye/mend_cameras
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ipc/eye/mend_cameras/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 1

/datum/surgery_step/ipc/eye/mend_cameras/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending lenses and wires in [target]'s cameras with \the [tool].",
	"You start mending lenses and wires in [target]'s cameras with the [tool].")
	..()

/datum/surgery_step/ipc/eye/mend_cameras/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends the lenses and wires in [target]'s cameras with \the [tool].</span>",
	"<span class='notice'>You mend the lenses abd wires in [target]'s cameras with \the [tool].</span>")
	/* surgery_victim.cure_nearsighted(EYE_DAMAGE_TRAIT)
	surgery_victim.sdisabilities &= ~BLIND
	eyes.damage = 0
	eyes.surgery_stage = BP_DEFAULT_OS
 */
/datum/surgery_step/ipc/eye/mend_cameras/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s cameras with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, denting [target]'s cameras with \the [tool]!</span>")
	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/nanopaste) || istype(tool, /obj/item/weapon/bonegel))
		BP.take_damage(0, 6, used_weapon = tool)

	else if(iswrenching(tool))
		BP.take_damage(12, 0, used_weapon = tool)
		BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(dam_amt,0)
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "<span class='warning italics'>SEVERE VISUAL SENSOR DAMAGE DETECTED. %REACTION_OVERLOAD%.</span>")
	target.blinded += 3.0

