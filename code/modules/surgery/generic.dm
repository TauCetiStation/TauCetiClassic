//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/stack/medical/suture = 100,
	/obj/item/weapon/cautery = 100,
	/obj/item/clothing/mask/cigarette = 75,
	/obj/item/weapon/lighter = 50,
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open && target_zone != O_MOUTH

/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [BP.name] with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Your [BP.name] is being burned!",1)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s [BP.name] with \the [tool].</span>")
	BP.open = 0
	BP.status &= ~ORGAN_BLEEDING

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(0, 3, used_weapon = tool)

/datum/surgery_step/generic/cut_limb
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 110
	max_duration = 160
	allowed_species = null

/datum/surgery_step/generic/cut_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone == O_EYES) // there are specific steps for eye surgery
		return 0
	if (!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	return target_zone != BP_CHEST && target_zone != BP_GROIN && target_zone != BP_HEAD

/datum/surgery_step/generic/cut_limb/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to cut off [target]'s [BP.name] with \the [tool]." , \
	"You are beginning to cut off [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Your [BP.name] is being ripped apart!",1)
	..()

/datum/surgery_step/generic/cut_limb/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cuts off [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You cut off [target]'s [BP.name] with \the [tool].</span>")
	BP.droplimb(null, TRUE)

/datum/surgery_step/generic/cut_limb/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawwing through the bone in [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawwing through the bone in [target]'s [BP.name] with \the [tool]!</span>")
	BP.fracture()
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)
//////////////////////////////////////////////////////////////////
//						COMMON ROBOTIC STEPS					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc/generic/pry_open
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ipc/generic/pry_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 1

/datum/surgery_step/ipc/generic/pry_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to pry open [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You start to pry open [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "%[BP.name]'s MAINTENANCE HATCH% DAMAGE DETECTED. CEASE APPLIED DAMAGE.")
	..()

/datum/surgery_step/ipc/generic/pry_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] pries open [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You pry open [target]'s [BP.name]'s maintenace hatch with \the [tool].</span>")
	BP.open = 2

/datum/surgery_step/ipc/generic/pry_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(12, 0, used_weapon = tool)
