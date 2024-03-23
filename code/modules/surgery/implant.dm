//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	allowed_species = null

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && !(BP.status & ORGAN_BLEEDING) && (target_zone != BP_CHEST || target.op_stage.ribcage == 2)

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return 1
		if (BP_CHEST)
			return 3
		if (BP_GROIN)
			return 2
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return "cranial"
		if (BP_CHEST)
			return "thoracic"
		if (BP_GROIN)
			return "abdominal"
	return ""

/datum/surgery_step/cavity/proc/remove_from_cavity(mob/user, mob/target, obj/obj_to_remove, obj/item/organ/external/BP, obj/tool)
	BP.implants -= obj_to_remove
	for(var/datum/wound/W in BP.wounds)
		if(obj_to_remove in W.embedded_objects)
			W.embedded_objects -= obj_to_remove
			break
	obj_to_remove.forceMove(get_turf(target))
	if(isitem(obj_to_remove))
		var/obj/item/I = obj_to_remove
		I.item_actions_special = initial(I.item_actions_special)
		I.remove_item_actions(target)
	user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You take [obj_to_remove] out of incision on [target]'s [BP.name]s with \the [tool].</span>" )

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && !BP.cavity && !BP.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] makes some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>", \
	"<span class='notice'>You make some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>" )

/datum/surgery_step/cavity/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && BP.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(BP)] cavity wall with \the [tool].", \
	"You start mending [target]'s [get_cavity(BP)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] mends [target]'s [get_cavity(BP)] cavity walls with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s [get_cavity(BP)] cavity walls with \the [tool].</span>" )

/datum/surgery_step/cavity/close_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(0, 20, used_weapon = tool)

/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && !BP.hidden && BP.cavity && tool.w_class <= get_max_wclass(BP)

/datum/surgery_step/cavity/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(BP)] cavity.", \
	"You start putting \the [tool] inside [target]'s [get_cavity(BP)] cavity." )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)

	user.visible_message("<span class='notice'>[user] puts \the [tool] inside [target]'s [get_cavity(BP)] cavity.</span>", \
	"<span class='notice'>You put \the [tool] inside [target]'s [get_cavity(BP)] cavity.</span>" )
	if (tool.w_class > get_max_wclass(BP)/2 && prob(50) && BP.sever_artery())
		to_chat(user, "<span class='warning'>You tear some blood vessels trying to fit such a big object in this cavity.</span>")
		BP.owner.custom_pain("You feel something rip in your [BP.name]!", 1)
	if(istype(tool, /obj/item/gland))	//Abductor surgery integration
		if(target_zone != BP_CHEST)
			return
		else
			var/obj/item/gland/gland = tool
			user.drop_from_inventory(gland, target)
			gland.Inject(target)
			BP.cavity = 0
			return
	user.drop_from_inventory(tool, target)
	BP.hidden = tool
	BP.cavity = 0
	tool.item_actions_special = TRUE
	tool.add_item_actions(target)

/datum/surgery_step/cavity/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/cavity/implant_removal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		if(BP.stage == 3)
			return FALSE

		return BP && ((BP.open == 3 && BP.body_zone == BP_CHEST) || (BP.open == 2))

/datum/surgery_step/cavity/implant_removal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts poking around inside the incision on [target]'s [BP.name] with \the [tool].", \
	"You start poking around inside the incision on [target]'s [BP.name] with \the [tool]" )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	if(BP.implants.len)
		var/list/list_of_embed_types = list()
		var/list/embed_object_shrapnel = list()
		var/list/embed_object_implants = list()
		var/list/embed_object_else = list()
		for(var/embed_object in BP.implants)
			if(istype(embed_object, /obj/item/weapon/shard/shrapnel))
				embed_object_shrapnel += embed_object
				continue
			if(istype(embed_object, /obj/item/weapon/implant))
				embed_object_implants += embed_object
				continue
			embed_object_else += embed_object
		for(var/atom/embed_object as anything in embed_object_implants)
			embed_object_implants[embed_object] = image(icon = embed_object.icon, icon_state = embed_object.icon_state)
		for(var/atom/embed_object as anything in embed_object_else)
			embed_object_else[embed_object] = image(icon = embed_object.icon, icon_state = embed_object.icon_state)
		if(embed_object_shrapnel.len)
			list_of_embed_types += list("Shrapnel" = image(icon = 'icons/obj/shards.dmi', icon_state = "shrapnellarge"))
		if(embed_object_implants.len)
			list_of_embed_types += list("Implants" = embed_object_implants[pick(embed_object_implants)])
		if(embed_object_else.len)
			list_of_embed_types += list("Else" = embed_object_else[pick(embed_object_else)])
		var/list_to_choose = show_radial_menu(user, target, list_of_embed_types, radius = 30, require_near = TRUE, tooltips = TRUE)
		if(!list_to_choose)
			user.visible_message("<span class='notice'>[user] removes \the [tool] from [target]'s [BP.name].</span>", \
			"<span class='notice'>There's something inside [target]'s [BP.name], but you decided not to touch it.</span>" )
			return
		switch(list_to_choose)
			if("Shrapnel")
				var/atom/picked_obj = pick(embed_object_shrapnel)
				remove_from_cavity(user, target, picked_obj, BP, tool)
			if("Implants")
				var/choosen_object = show_radial_menu(user, target, embed_object_implants, radius = 50, require_near = TRUE, tooltips = TRUE)
				if(choosen_object)
					var/obj/item/weapon/implant/imp = choosen_object
					for(var/datum/wound/W in BP.wounds)
						if(imp in W.embedded_objects)
							W.embedded_objects -= imp
							break
					if(istype(imp, /obj/item/weapon/implant/skill))
						var/obj/item/weapon/implant/skill/skill_impant = imp
						skill_impant.removed()
					imp.implant_removal(target)
					imp.imp_in = null
					imp.implanted = FALSE
					if(istype(imp, /obj/item/weapon/implant/storage))
						var/obj/item/weapon/implant/storage/Simp = imp
						Simp.removed()
					remove_from_cavity(user, target, choosen_object, BP, tool)
					target.sec_hud_set_implants()
			if("Else")
				var/choosen_object = show_radial_menu(user, target, embed_object_else, radius = 50, require_near = TRUE, tooltips = TRUE)
				if(choosen_object)
					if(istype(choosen_object, /mob/living/simple_animal/borer))
						var/mob/living/simple_animal/borer/worm = choosen_object
						if(worm.controlling)
							target.release_control()
						worm.detatch()
					remove_from_cavity(user, target, choosen_object, BP, tool)
		playsound(target, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)

	else if (BP.hidden)
		user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You take something out of incision on [target]'s [BP.name]s with \the [tool].</span>" )
		BP.hidden.forceMove(get_turf(target))
		BP.hidden.item_actions_special = initial(BP.hidden.item_actions_special)
		BP.hidden.remove_item_actions(target)
		if(!BP.hidden.blood_DNA)
			BP.hidden.blood_DNA = list()
		BP.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
		BP.hidden.update_icon()
		BP.hidden = null
	else
		user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>" )

/datum/surgery_step/cavity/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
	if (BP.implants.len)
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if (prob(fail_prob))
			var/obj/item/weapon/implant/imp = BP.implants[1]
			user.visible_message("<span class='warning'>Внутри [CASE(BP, GENITIVE_CASE)] [target] что-то пищит!</span>")
			playsound(imp, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
			spawn(25)
				imp.activate()
