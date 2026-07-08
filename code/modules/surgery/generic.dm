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
