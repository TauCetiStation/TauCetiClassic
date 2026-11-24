/datum/surgery_step/clamp
	name = "Clamp"
	allowed_qualities = list(
		QUALITY_SURGERY_CLAMP,
		QUALITY_WRENCHING
		)

	allowed_species = list("exclude", DIONA)
	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/clamp/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	if(!ishuman(surgery_victim))
		return FALSE
	if(!..())
		return FALSE
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(bodypart.open == BP_DEFAULT_OS)
	// Check open
		return FALSE

	if(bodypart.status & ORGAN_BLEEDING)
	// clamp bleedin if exist
		return TRUE
	else if(bodypart.trauma_kit || bodypart.burn_kit)
	 // tissue, if salvaged
		return TRUE
	else if(check_inside(bodypart))
		switch(target_zone)
			if(BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				if(bodypart.open >= BP_RETRACT_OS)
					return TRUE
			if(BP_HEAD, BP_CHEST)
			// implant or embreo remove
				if(bodypart.open == BP_RIBCAGE_OS)
					return TRUE
	else if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC && (bodypart.open == BP_RETRACT_OS || bodypart.open == BP_INTERNALS_OS))
		return TRUE
	else
	// operate organs
		switch(target_zone)
		//exclude operations
			if(O_EYES)
			//eyes
				var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
				if(!eyes)
					return FALSE
				if(eyes.surgery_stage == BP_RETRACT_OS)
					return TRUE
			if(O_MOUTH)
			//face reconstruction & plastic surgery
				var/obj/item/organ/external/head/head = bodypart
				if(BP_DEFAULT_OS < head.ps_status && head.ps_status <= BP_INTERNALS_OS) // 0 < x <= 3
					return TRUE
			if(BP_HEAD)
			//brain chips
				var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
				if(bodypart.open == BP_INTERNALS_OS && brain?.status & ORGAN_BLEEDING)
					//brain chips
					return TRUE
	return FALSE

/datum/surgery_step/clamp/begin_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	. = ..()
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(bodypart.status & ORGAN_BLEEDING)
	// clamp bleedin if exist
		msg = "<span class='notice'>[user] begin to clamping bleeders in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		self_msg = "<span class='notice'>You start to clamping bleeders in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		cp_msg = "The pain in your [bodypart.name] is maddening!"
		user.visible_message(msg, self_msg)
		surgery_victim.custom_pain(cp_msg, 1)

	else if(bodypart.trauma_kit || bodypart.burn_kit)
	 // tissue, if salvaged
		msg = "<span class='notice'>[user] begin to connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [bodypart.name].</span>"
		self_msg = "<span class='notice'>You start toconnecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [bodypart.name].</span>"
		cp_msg = "The pain in your [bodypart.name] is going to make you pass out!"
		surgery_victim.custom_pain(cp_msg, 1)
		user.visible_message(msg, self_msg)

	else if(check_inside(bodypart))
	// remove something inside
		if(!(locate(/obj/item/alien_embryo) in bodypart))
		// implant remove
			msg = "<span class='notice'>[user] begin to poking around inside the [surgery_victim]'s [bodypart.name] with \the [I].</span>"
			self_msg = "<span class='notice'>You start to poking around inside the [surgery_victim]'s [bodypart.name] with \the [I]</span>"
			cp_msg = "The pain in your chest is living hell!"
		else
		// alien remove
			msg = "<span class='notice'>[user] begin to pull something out from [surgery_victim]'s ribcage with \the [I].</span>"
			self_msg = "<span class='notice'>You start to pull something out from [surgery_victim]'s ribcage with \the [I].</span>"
			cp_msg = "Something hurts horribly in your chest!"

		switch(target_zone)
			if(BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				if(bodypart.open >= BP_RETRACT_OS)
					surgery_victim.custom_pain(cp_msg, 1)
					user.visible_message(msg, self_msg)
			if(BP_HEAD, BP_CHEST)
			// implant or embreo remove
				if(bodypart.open == BP_RIBCAGE_OS)
					surgery_victim.custom_pain(cp_msg, 1)
					user.visible_message(msg, self_msg)

	else if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC && (bodypart.open == BP_RETRACT_OS || bodypart.open == BP_INTERNALS_OS))
		msg = "<span class='notice'>[user] begin to [bodypart.open == BP_RETRACT_OS ? "loose" : "tighten" ] bolts on [surgery_victim]'s security panel with \the [I].</span>"
		self_msg = "<span class='notice'>You start to [bodypart.open == BP_RETRACT_OS ? "loose" : "tighten" ] bolts on [surgery_victim]'s security panel with \the [I].</span>"
		user.visible_message(msg, self_msg)

	else
	// operate organs
		switch(target_zone)
		//exclude operations
			if(O_EYES)
			//eyes
				var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
				if(eyes.surgery_stage == BP_RETRACT_OS)
					msg = "<span class='notice'>[user] begin to mending the nerves and lenses in [surgery_victim]'s eyes with \the [I].</span>"
					self_msg = "<span class='notice'>You start to mending the nerves and lenses in [surgery_victim]'s eyes with \the [I].</span>"
					user.visible_message(msg, self_msg)

			if(O_MOUTH)
			//face reconstruction & plastic surgery
				var/obj/item/organ/external/head/head = bodypart
				if(BP_DEFAULT_OS < head.ps_status && head.ps_status <= BP_INTERNALS_OS) // 0 < x <= 3
					msg = "<span class='notice'>[user] begin to [head.disfigured ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [I].</span>"
					self_msg = "<span class='notice'>You start to [head.disfigured ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [I].</span>"
					user.visible_message(msg, self_msg)

			if(BP_HEAD)
			//brain chips
				var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
				if(bodypart.open == BP_INTERNALS_OS && brain?.status & ORGAN_BLEEDING)
					//brain chips
					msg = "<span class='notice'>[user] begin to taking bone chips out of [surgery_victim]'s brain with \the [I].</span>"
					self_msg = "<span class='notice'>You start to taking bone chips out of [surgery_victim]'s brain with \the [I].</span>"
					user.visible_message(msg, self_msg)


/datum/surgery_step/clamp/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(bodypart.status & ORGAN_BLEEDING)
	//clamp bleeding
		msg = "<span class='notice'>[user] finish to clamping bleeders in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		self_msg = "<span class='notice'>You finish to clamping bleeders in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		bodypart.strap()
	else if(bodypart.trauma_kit || bodypart.burn_kit)
	//tissue
		msg = "<span class='notice'>[user] finishes to connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [bodypart.name].</span>"
		self_msg = "<span class='notice'>[user] finish to connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [bodypart.name].</span>"
		if(bodypart.trauma_kit)
			bodypart.trauma_kit = FALSE
			bodypart.heal_damage(20)
			bodypart.disinfect()
			bodypart.status &= ~ORGAN_BLEEDING
		if(bodypart.burn_kit)
			bodypart.burn_kit = FALSE
			bodypart.heal_damage(0, 20)
			bodypart.salve()
	else if(check_inside(bodypart))
	//implant remove
		msg = "<span class='notice'>[user] pull something out from [surgery_victim]'s ribcage with \the [I].</span>"
		self_msg = "<span class='notice'>You pull something out from [surgery_victim]'s ribcage with \the [I].</span>"
		if(length(bodypart.embedded_objects))
			remove_inside(user, surgery_victim, bodypart, I)
		else if(bodypart.hidden)

			bodypart.hidden.forceMove(get_turf(surgery_victim))
			bodypart.hidden.item_actions_special = initial(bodypart.hidden.item_actions_special)
			bodypart.hidden.remove_item_actions(surgery_victim)
			if(!bodypart.hidden.blood_DNA)
				bodypart.hidden.blood_DNA = list()
			bodypart.hidden.blood_DNA[surgery_victim.dna.unique_enzymes] = surgery_victim.dna.b_type
			bodypart.hidden.update_icon()
			bodypart.hidden = null
	else if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC && (bodypart.open == BP_RETRACT_OS || bodypart.open == BP_INTERNALS_OS))
		msg = "<span class='notice'>[user] finish to [bodypart.open == BP_RETRACT_OS ? "loose" : "tighten" ] bolts on [surgery_victim]'s security panel with \the [I].</span>"
		self_msg = "<span class='notice'>You finish to [bodypart.open == BP_RETRACT_OS ? "loose" : "tighten" ] bolts on [surgery_victim]'s security panel with \the [I].</span>"
		bodypart.open = bodypart.open == BP_INTERNALS_OS ? BP_RETRACT_OS : BP_INTERNALS_OS
	else
		var/obj/item/organ/external/head/head = bodypart
		switch(target_zone)
			if(O_EYES)
			//eyes
				fix_eyes(user, surgery_victim, I)
			if(O_MOUTH)
			//face && plastic surgery
				if(head.ps_status > BP_DEFAULT_OS)
					msg = "<span class='notice'>[user] finish to [head.disfigured ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [I].</span>"
					self_msg = "<span class='notice'>You finish to [head.disfigured ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [I].</span>"
					head.disfigured = FALSE
				head.ps_status = head.ps_status == BP_SCALPEL_OS ? BP_RETRACT_OS : BP_INTERNALS_OS
			if(BP_HEAD)
				if(bodypart.open == BP_INTERNALS_OS)
				//brain chips
					msg = "<span class='notice'>[user] finish to taking bone chips out of [surgery_victim]'s brain with \the [I].</span>"
					self_msg = "<span class='notice'>You finish to taking bone chips out of [surgery_victim]'s brain with \the [I].</span>"
					var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
					brain.status &= ~ORGAN_BLEEDING

	surgery_victim.custom_pain(cp_msg, 1)
	user.visible_message(msg, self_msg)

/datum/surgery_step/proc/remove_from_cavity(mob/user, mob/target, obj/obj_to_remove, obj/item/organ/external/bodypart, obj/I)
	bodypart.embedded_objects -= obj_to_remove
	for(var/datum/wound/W in bodypart.wounds)
		if(obj_to_remove in W.embedded_objects)
			W.embedded_objects -= obj_to_remove
			break
	obj_to_remove.forceMove(get_turf(target))
	if(isitem(obj_to_remove))
		var/obj/item/something = obj_to_remove
		something.item_actions_special = initial(something.item_actions_special)
		something.remove_item_actions(target)

/datum/surgery_step/proc/check_inside(obj/item/organ/external/bodypart)
	for(var/something in bodypart.contents)
		if(!isorgan(something))
			return TRUE
	return FALSE

/datum/surgery_step/proc/remove_inside(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/organ/external/bodypart, obj/item/I)
	var/list/list_of_embed_types = list()
	var/list/embed_object_shrapnel = list()
	var/list/embed_object_implants = list()
	var/list/embed_object_else = list()
	for(var/embed_object in bodypart.embedded_objects)
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
	var/list_to_choose = show_radial_menu(user, surgery_victim, list_of_embed_types, radius = 30, require_near = TRUE, tooltips = TRUE)
	if(!list_to_choose)
		msg = "<span class='notice'>[user] removes \the [I] from [surgery_victim]'s [bodypart.name].</span>"
		self_msg = "<span class='notice'>There's something inside [surgery_victim]'s [bodypart.name], but you decided not to touch it.</span>"
		user.visible_message(msg, self_msg)
		return FALSE
	switch(list_to_choose)
		if("Shrapnel")
			var/atom/picked_obj = pick(embed_object_shrapnel)
			remove_from_cavity(user, surgery_victim, picked_obj, bodypart, I)
		if("Implants")
			var/choosen_object = show_radial_menu(user, surgery_victim, embed_object_implants, radius = 50, require_near = TRUE, tooltips = TRUE)
			if(choosen_object)
				var/obj/item/weapon/implant/imp = choosen_object
				imp.eject()
				remove_from_cavity(user, surgery_victim, choosen_object, bodypart, I)
				surgery_victim.sec_hud_set_implants()
		if("Else")
			var/choosen_object = show_radial_menu(user, surgery_victim, embed_object_else, radius = 50, require_near = TRUE, tooltips = TRUE)
			if(choosen_object)
				if(isborer(choosen_object))
					var/mob/living/simple_animal/borer/worm = choosen_object
					if(worm.controlling)
						surgery_victim.release_control()
					worm.detatch()
				if(isalienembryo(choosen_object))
				//alien reemove
					var/obj/item/alien_embryo/ae = choosen_object
					ae.detach()
				remove_from_cavity(user, surgery_victim, choosen_object, bodypart, I)
	playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
