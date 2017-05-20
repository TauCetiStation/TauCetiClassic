//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/weapon/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!ishuman(target))
			return 0

		var/datum/organ/external/BP = target.get_bodypart(target_zone)

		var/internal_bleeding = 0
		for(var/datum/wound/W in BP.wounds)
			if(W.internal)
				internal_bleeding = 1
				break

		return BP.open >= 2 && internal_bleeding

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts patching the damaged vein in [target]'s [BP.name] with \the [tool]." , \
		"You start patching the damaged vein in [target]'s [BP.name] with \the [tool].")
		target.custom_pain("The pain in [BP.name] is unbearable!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has patched the damaged vein in [target]'s [BP.name] with \the [tool].</span>", \
			"<span class='notice'>You have patched the damaged vein in [target]'s [BP.name] with \the [tool].</span>")

		for(var/datum/wound/W in BP.wounds)
			if(W.internal)
				BP.wounds -= W
				BP.update_damages()

		if (ishuman(user) && prob(40))
			user:bloody_hands(target, 0)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
		"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")
		BP.take_damage(5, 0)
