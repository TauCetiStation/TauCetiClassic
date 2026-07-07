
#define TISSUE_ACTION       "connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [bodypart.name]"
#define CLAMP_ACTION        "clamping bleeders in [surgery_victim]'s [bodypart.name] with \the [tool]"
#define PULL_FROM_ACTION    "pull something out from [surgery_victim]'s ribcage with \the [tool]"
#define FACE_MENDING_ACTION "[head.disfigured ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [tool]"
#define BONE_CHIPS_ACTION   "taking bone chips out of [surgery_victim]'s brain with \the [tool]"

/datum/surgery_step/clamp
	allowed_qualities = list(
		QUALITY_CLAMP
		)

	allowed_species = list("exclude", IPC, DIONA)
	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/clamp/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
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
		msg = "[user] starts [CLAMP_ACTION]."
		self_msg = "You start [CLAMP_ACTION]."
		cp_msg = "The pain in your [bodypart.name] is maddening!"
		user.visible_message(msg, self_msg)
		surgery_victim.custom_pain(cp_msg, 1)
		return TRUE
	else if(bodypart.trauma_kit || bodypart.burn_kit)
	 // tissue, if salvaged
		msg = "<span class='notice'>[user] starts [TISSUE_ACTION].</span>"
		self_msg = "<span class='notice'>You start [TISSUE_ACTION].</span>"
		cp_msg = "The pain in your [bodypart.name] is going to make you pass out!"
		surgery_victim.custom_pain(cp_msg, 1)
		user.visible_message(msg, self_msg)
		return TRUE
	else if(check_inside(bodypart))
	// remove something inside
		if(!(locate(/obj/item/alien_embryo) in bodypart))
		// implant remove
			msg = "[user] starts [POKING_ACTION]."
			self_msg = "You start [POKING_ACTION]"
			cp_msg = "The pain in your chest is living hell!"
		else
		// alien remove
			msg = "[user] starts to [PULL_FROM_ACTION]."
			self_msg = "You start to [PULL_FROM_ACTION]."
			cp_msg = "Something hurts horribly in your chest!"

		switch(target_zone)
			if(BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				if(bodypart.open >= BP_RETRACT_OS)
					surgery_victim.custom_pain(cp_msg, 1)
					user.visible_message(msg, self_msg)
					return TRUE
			if(BP_HEAD, BP_CHEST)
			// implant or embreo remove
				if(bodypart.open >= BP_RIBCAGE_OS)
					surgery_victim.custom_pain(cp_msg, 1)
					user.visible_message(msg, self_msg)
					return TRUE
	else
	// operate organs
		switch(target_zone)
		//exclude operations
			if(O_EYES)
			//eyes
				var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
				if(!eyes)
					return FALSE
				if(eyes.surgery_stage == BP_RETRACT_OS)
					msg = "[user] starts [EYES_MENDING_ACTION]."
					self_msg = "You start [EYES_MENDING_ACTION]."
					user.visible_message(msg, self_msg)
					return TRUE
			if(O_MOUTH)
			//face reconstruction & plastic surgery
				var/obj/item/organ/external/head/head = bodypart
				if(BP_DEFAULT_OS < head.ps_status && head.ps_status <= BP_INTERNALS_OS) // 0 < x <= 3
					msg = "[user] starts [FACE_MENDING_ACTION]."
					self_msg = "You start [FACE_MENDING_ACTION]."
					user.visible_message(msg, self_msg)
					return TRUE
			if(BP_HEAD)
			//brain chips
				var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
				if(bodypart.open == BP_INTERNALS_OS && brain?.status & ORGAN_BLEEDING)
					//brain chips
					msg = "[user] starts [BONE_CHIPS_ACTION]."
					self_msg = "You start [BONE_CHIPS_ACTION]."
					user.visible_message(msg, self_msg)
					return TRUE
	return FALSE

/datum/surgery_step/clamp/prepare_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	return TRUE //may be next time add something

/datum/surgery_step/clamp/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(bodypart.status & ORGAN_BLEEDING)
	//clamp bleeding
		msg = "<span class='notice'>[user] finish [CLAMP_ACTION].</span>"
		self_msg = "<span class='notice'>You finish [CLAMP_ACTION].</span>"
		bodypart.strap()
	else if(bodypart.trauma_kit || bodypart.burn_kit)
	//tissue
		msg = "<span class='notice'>[user] finishes [TISSUE_ACTION].</span>"
		self_msg = "<span class='notice'>[user] finish [TISSUE_ACTION].</span>"
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
		msg = "<span class='notice'>[user] [PULL_FROM_ACTION].</span>"
		self_msg = "<span class='notice'>You [PULL_FROM_ACTION].</span>"
		if(length(bodypart.embedded_objects))
			remove_inside(user, surgery_victim, bodypart, tool)
		else if(bodypart.hidden)

			bodypart.hidden.forceMove(get_turf(surgery_victim))
			bodypart.hidden.item_actions_special = initial(bodypart.hidden.item_actions_special)
			bodypart.hidden.remove_item_actions(surgery_victim)
			if(!bodypart.hidden.blood_DNA)
				bodypart.hidden.blood_DNA = list()
			bodypart.hidden.blood_DNA[surgery_victim.dna.unique_enzymes] = surgery_victim.dna.b_type
			bodypart.hidden.update_icon()
			bodypart.hidden = null
	else
		var/obj/item/organ/external/head/head = bodypart
		switch(target_zone)
			if(O_EYES)
			//eyes
				fix_eyes(user, surgery_victim, tool)
			if(O_MOUTH)
			//face && plastic surgery
				if(head.ps_status > BP_DEFAULT_OS)
					msg = "<span class='notice'>[user] finish [FACE_MENDING_ACTION].</span>"
					self_msg = "<span class='notice'>You finish [FACE_MENDING_ACTION].</span>"
					head.disfigured = FALSE
				head.ps_status = head.ps_status == BP_SCALPEL_OS ? BP_RETRACT_OS : BP_INTERNALS_OS
			if(BP_HEAD)
				if(bodypart.open == BP_INTERNALS_OS)
				//brain chips
					msg = "<span class='notice'>[user] finish [BONE_CHIPS_ACTION].</span>"
					self_msg = "<span class='notice'>You finish [BONE_CHIPS_ACTION].</span>"
					var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
					brain.status &= ~ORGAN_BLEEDING

	surgery_victim.custom_pain(cp_msg, 1)
	user.visible_message(msg, self_msg)


/datum/surgery_step/clamp/fail_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	msg = "<span class='warning'>[user]'s [FAIL_ACTION] [surgery_victim]!</span>"
	self_msg = "<span class='warning'>Your [FAIL_ACTION] [surgery_victim]!</span>"

	if(bodypart.status & ORGAN_BLEEDING)
	//clamp bleeding
		bodypart.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
		bodypart.sever_artery()
	else if(bodypart.trauma_kit || bodypart.burn_kit)
	//tissue
		bodypart.trauma_kit = FALSE
		bodypart.burn_kit = FALSE
		bodypart.take_damage(5, 0, used_weapon = tool)
	else if(check_inside(bodypart))
	//implant remove
		bodypart.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
		if(length(bodypart.embedded_objects))
			var/fail_prob = 10
			fail_prob += 100 - tool_quality(tool)
			var/obj/item/weapon/implant/imp = locate(/obj/item/weapon/implant) in bodypart.embedded_objects
			if(prob(fail_prob))
				user.visible_message("<span class='warning'>Something cheeps inside [CASE(bodypart, GENITIVE_CASE)] [surgery_victim]!</span>")
				playsound(imp, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
				addtimer(CALLBACK(imp, TYPE_PROC_REF(/obj/item/weapon/implant, use_implant)), 3 SECONDS)
	else
		switch(target_zone)
			if(O_EYES)
			//eyes
				var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
				bodypart.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
				eyes.take_damage(5, 0)
			if(O_MOUTH)
			//face
				bodypart.take_damage(15, 0, DAM_SHARP|DAM_EDGE, tool)
				surgery_victim.losebreath += 10
			if(BP_HEAD)
				if(bodypart.open == BP_INTERNALS_OS)
				//brain chips
					bodypart.take_damage(30, 0, DAM_SHARP, tool)

	user.visible_message(msg, self_msg)


/datum/surgery_step/proc/remove_from_cavity(mob/user, mob/target, obj/obj_to_remove, obj/item/organ/external/bodypart, obj/tool)
	bodypart.embedded_objects -= obj_to_remove
	for(var/datum/wound/W in bodypart.wounds)
		if(obj_to_remove in W.embedded_objects)
			W.embedded_objects -= obj_to_remove
			break
	obj_to_remove.forceMove(get_turf(target))
	if(isitem(obj_to_remove))
		var/obj/item/I = obj_to_remove
		I.item_actions_special = initial(I.item_actions_special)
		I.remove_item_actions(target)

/datum/surgery_step/proc/check_inside(obj/item/organ/external/bodypart)
	for(var/something in bodypart.contents)
		if(!isorgan(something))
			return TRUE
	return FALSE

/datum/surgery_step/proc/remove_inside(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/organ/external/bodypart, obj/item/tool)
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
		msg = "<span class='notice'>[user] removes \the [tool] from [surgery_victim]'s [bodypart.name].</span>"
		self_msg = "<span class='notice'>There's something inside [surgery_victim]'s [bodypart.name], but you decided not to touch it.</span>"
		user.visible_message(msg, self_msg)
		return FALSE
	switch(list_to_choose)
		if("Shrapnel")
			var/atom/picked_obj = pick(embed_object_shrapnel)
			remove_from_cavity(user, surgery_victim, picked_obj, bodypart, tool)
		if("Implants")
			var/choosen_object = show_radial_menu(user, surgery_victim, embed_object_implants, radius = 50, require_near = TRUE, tooltips = TRUE)
			if(choosen_object)
				var/obj/item/weapon/implant/imp = choosen_object
				imp.eject()
				remove_from_cavity(user, surgery_victim, choosen_object, bodypart, tool)
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
				remove_from_cavity(user, surgery_victim, choosen_object, bodypart, tool)
	playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
