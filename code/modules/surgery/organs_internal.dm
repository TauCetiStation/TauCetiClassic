

//////////////////////////////////////////////////////////////////
//					 ORGANS SURGERY	          					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/organ_manipulation
	priority = 2
	allowed_species = list("exclude", IPC, DIONA, PODMAN)
	var/obj/item/organ/internal/I = null

/datum/surgery_step/organ_manipulation/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(target_zone in list(O_EYES , O_MOUTH, BP_HEAD))
		return 0

	return BP && BP.open >= 2 && !(BP.status & ORGAN_BLEEDING) && (target_zone != BP_CHEST || target.op_stage.ribcage == 2)

/datum/surgery_step/organ_manipulation/place
	priority = 0
	allowed_tools = list(/obj/item/organ/internal = 100)

	min_duration = 50
	max_duration = 50

/datum/surgery_step/organ_manipulation/place/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE

	if(target_zone in list(O_EYES , O_MOUTH, BP_HEAD))
		return FALSE

	var/obj/item/organ/internal/I = tool
	if(I.requires_robotic_bodypart)
		user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
		return FALSE

	if(target_zone != I.parent_bodypart)
		user.visible_message ( "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return FALSE

	if(I.damage > (I.max_damage * 0.75))
		user.visible_message ( "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
		return FALSE

	if(target.get_int_organ(I))
		user.visible_message ( "<span class='warning'> \The [target] already has [I].</span>")
		return FALSE

	if(!(target.get_species() in I.compability))
		user.visible_message ( "<span class='warning'> \The [I] not compability to [target]</span>")
		return FALSE

	return TRUE


/datum/surgery_step/organ_manipulation/place/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
		"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")

	..()

/datum/surgery_step/organ_manipulation/place/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	I = tool
	if(target.get_int_organ(I))
		user.visible_message ( "<span class='warning'> \The [target] already has [I].</span>")
		return FALSE
	user.drop_from_inventory(tool)
	I.insert_organ(target)
	user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target].</span>", \
	"<span class='notice'> You have transplanted \the [tool] into [target].</span>")
	I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/organ_manipulation/place/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)


/datum/surgery_step/organ_manipulation/remove
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/organ_manipulation/remove/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		if(BP.stage == 3)
			return FALSE

		return BP && ((BP.open == 3 && BP.body_zone == BP_CHEST) || (BP.open == 2))

/datum/surgery_step/organ_manipulation/remove/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts poking around inside the incision on [target]'s [BP.name] with \the [tool].", \
	"You start poking around inside the incision on [target]'s [BP.name] with \the [tool]" )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/organ_manipulation/remove/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.bodypart_organs.len)
		var/list/embed_organs = list()
		for(var/embed_organ in BP.bodypart_organs)
			embed_organs += embed_organ
		for(var/atom/embed_organ as anything in embed_organs)
			embed_organs[embed_organ] = image(icon = embed_organ.icon, icon_state = initial(embed_organ.icon_state))
		var/choosen_organ = show_radial_menu(user, target, embed_organs, radius = 50, require_near = TRUE, tooltips = TRUE)
		if(!choosen_organ)
			user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>")
			return
		if(!(BP.open >= 2  && (target_zone != BP_CHEST || target.op_stage.ribcage == 2)))
			return
		var/obj/item/organ/internal/I = choosen_organ
		I.status |= ORGAN_CUT_AWAY
		I.remove(target)
		I.loc = get_turf(target)
		BP.bodypart_organs  -= I
		playsound(target, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)

	else
		user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>" )

/datum/surgery_step/organ_manipulation/remove/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)


/datum/surgery_step/organ_manipulation/treat_necrosis
	priority = 0

	allowed_tools = list(
		/obj/item/weapon/reagent_containers/dropper = 100,
		/obj/item/weapon/reagent_containers/glass/bottle = 90,
		/obj/item/weapon/reagent_containers/glass/beaker = 75,
		/obj/item/weapon/reagent_containers/spray = 60,
	)

	can_infect = FALSE

	min_duration = 110
	max_duration = 150

/datum/surgery_step/organ_manipulation/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/weapon/reagent_containers/C = tool
		if(!C.reagents.has_reagent("peridaxon"))
			user.visible_message(
				"[user] looks at \the [tool] and ponders.",
				"You are not sure if \the [tool] contains the peridaxon necessary to treat the necrosis.",
			)
			return FALSE

		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		if(BP.stage == 3)
			return FALSE

		return BP && ((BP.open == 3 && BP.body_zone == BP_CHEST) || (BP.open == 2))


/datum/surgery_step/organ_manipulation/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if (BP.bodypart_organs.len)
		var/list/embed_organs = list()
		for(var/embed_organ in BP.bodypart_organs)
			var/obj/item/organ/internal/IO = embed_organ
			if(IO.status & ORGAN_DEAD)
				embed_organs += embed_organ
		if(!embed_organs)
			user.visible_message("<span class='warning'>The [BP.name] seems to already be in fine condition!</span>")
			return

		user.visible_message(
			"[user] starts applying medication to the affected tissue in [target]'s [BP.name] with \the [tool].",
			"You start applying medication to the affected tissue in [target]'s [BP.name] with \the [tool].",
			)

	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!")

	return ..()

/datum/surgery_step/organ_manipulation/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if (BP.bodypart_organs.len)
		var/list/embed_organs = list()
		for(var/embed_organ in BP.bodypart_organs)
			var/obj/item/organ/internal/IO = embed_organ
			if(IO.status & ORGAN_DEAD)
				embed_organs += embed_organ
		for(var/atom/embed_organ as anything in embed_organs)
			embed_organs[embed_organ] = image(icon = embed_organ.icon, icon_state = initial(embed_organ.icon_state))
		var/choosen_organ = show_radial_menu(user, target, embed_organs, radius = 50, require_near = TRUE, tooltips = TRUE)
		if(!choosen_organ)
			user.visible_message("<span class='warning'>The [BP.name] seems to already be in fine condition!</span>")
			return

		var/obj/item/organ/internal/IO = choosen_organ
		var/obj/item/weapon/reagent_containers/container = tool
		var/Peridaxon = FALSE

		if(container.reagents.has_reagent("peridaxon"))
			Peridaxon = TRUE

		var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
		if(trans > 0)
			container.reagents.reaction(target)	//technically it's contact, but the reagents are being applied to internal tissue

			if(Peridaxon)
				IO.status &= ~ORGAN_DEAD
				IO.germ_level = 0
				IO.damage = 0

			user.visible_message(
				"<span class='notice'>[user] applies [trans] units of the solution to affected tissue in [target]'s [BP.name]</span>",
				"<span class='notice'>You apply [trans] units of the solution to affected tissue in [target]'s [BP.name] with \the [tool].</span>",
			)

	return

/datum/surgery_step/organ_manipulation/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message(
		"<span class='warning'>[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [BP.name] with the [tool]!</span>",
		"<span class='warning'>Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [BP.name] with the [tool]!</span>",
	)

	//no damage or anything, just wastes medicine

	return
