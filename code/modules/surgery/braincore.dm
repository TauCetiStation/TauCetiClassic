/datum/surgery_step/brain/insert_brain
	allowed_tools = list(
	/obj/item/organ/internal/brain = 100
	)
	allowed_species = list("exclude", IPC, DIONA)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/brain/insert_brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/internal/I = tool
	if(!(target.get_species() in I.compability))
		user.visible_message ( "<span class='warning'> \The [I] not compability to [target]</span>")
		return FALSE

	if(I.requires_robotic_bodypart)
		user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
		return FALSE

	return ..() && target.op_stage.skull == 1 && !target.has_brain()

/datum/surgery_step/brain/insert_brain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts inserting [tool] into [target]'s [BP.name].",
	"You start inserting [tool] into [target]'s [BP.name].")
	..()

/datum/surgery_step/brain/insert_brain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] inserts [tool] into [target]'s [BP.name].</span>",
	"<span class='notice'>You inserts [tool] into [target]'s [BP.name].</span>")

	if(!istype(tool, /obj/item/organ/internal/brain))
		return

	var/obj/item/organ/internal/brain/B = tool
	if(target.get_int_organ(B))
		user.visible_message ( "<span class='warning'> \The [target] already has [B].</span>")
		return FALSE

	//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
	if(target.key)//Revised. /N
		target.ghostize()
	if(B.brainmob)
		if(B.brainmob.mind)
			B.brainmob.mind.transfer_to(target)
		else
			target.key = B.brainmob.key
		target.dna = B.brainmob.dna
	user.drop_from_inventory(tool)
	B.insert_organ(target)
	target.timeofdeath = min(target.timeofdeath, world.time - DEFIB_TIME_LIMIT) // so they cannot be defibbed
	ADD_TRAIT(target, TRAIT_NO_CLONE, GENERIC_TRAIT) // so they cannot be cloned


/datum/surgery_step/brain/insert_brain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>")
	target.apply_damage(5, BRUTE, BP)
