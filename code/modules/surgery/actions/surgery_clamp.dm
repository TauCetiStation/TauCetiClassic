/datum/surgery_step/clamp
	allowed_qualities = list(
		QUALITY_CLAMP,
		)

	allowed_species = list()
	min_duration = 60
	max_duration = 80

/datum/surgery_step/clamp/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	if(!BP)
		return FALSE
	if(BP.open == BP_DEFAULT_STATE)
		return FLASE

	if(BP.status & ORGAN_BLEEDING)
	//clamp bleedin if exist
		return TRUE
	else if(BP.stage & BP_KIT)
	 //tissue, if salvaged
		return TRUE
	else if(check_inside(BP))
	//remove something inside
	//implant remove
		switch(target_zone)
			if(BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				if(BP.open >= BP_RETRACTOR_OPEN_STATE)
					return TRUE
			if(BP_HEAD, BP_CHEST)
			// implant or embreo remove
				if(BP.open >= BP_SAW_INTERNALS_OPEN_STATE)
					return TRUE
	else      // operate organs
		switch(target_zone)
		//exclude operations
			if(O_EYES)
			//eyes
				var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
				if(!eyes)
					return FALSE
				if(eyes.surgery_stage == PREPARED)
					return TRUE
			if(O_MOUTH)
			//face reconstruction & plastic surgery
				var/obj/item/organ/external/head/head = BP
				if(head.ps_status <= PREPARED)
					return TRUE
			if(BP_HEAD)
			//brain chips
				var/obj/item/organ/external/head/head = BP
				var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
				if(BP.open == BP_SAW_INTERNALS_OPEN_STATE)
					if(brain?.status & ORGAN_BLEEDING)
						return TRUE
	return FALSE


/datum/surgery_step/clamp/prepare_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	return TRUE //may be next time add somethink

/datum/surgery_step/clamp/begin_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)

	if(BP.status & ORGAN_BLEEDING)
	//clamp bleeding
		msg = "[user] starts clamping bleeders in [surgery_victim]'s [BP.name] with \the [tool]."
		self_msg = "You start clamping bleeders in [surgery_victim]'s [BP.name] with \the [tool]."
		cp_msg = "The pain in your [BP.name] is maddening!"
	else if(BP.stage & BP_KIT)
	//tissue
		msg = "<span class='notice'>[user] starts connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [BP.name].</span>"
		self_msg = "<span class='notice'>You start connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [BP.name].</span>"
		cp_msg = "The pain in your [BP.name] is going to make you pass out!"
	else if(check_inside(BP))
		if(!(locate(/obj/item/alien_embryo) in surgery_victim))
		//implant remove
			msg = "[user] starts poking around inside the incision on [surgery_victim]'s [BP.name] with \the [tool]."
			self_msg = "You start poking around inside the incision on [surgery_victim]'s [BP.name] with \the [tool]"
			cp_msg = "The pain in your chest is living hell!"
		else
		//alien remove
			msg = "[user] starts to pull something out from [surgery_victim]'s ribcage with \the [tool]."
			self_msg = "You start to pull something out from [surgery_victim]'s ribcage with \the [tool]."
			cp_msg = "Something hurts horribly in your chest!"
	else
		var/obj/item/organ/external/head/head = BP
		switch(target_zone)
			if(O_EYES)
			//eyes
				msg = "[user] starts mending the nerves and lenses in [surgery_victim]'s eyes with \the [tool]."
				self_msg = "You start mending the nerves and lenses in [surgery_victim]'s eyes with the [tool]."
			if(O_MOUTH)
				//face reconstruction && plastic surg
				if(head.ps_status > NORMAL)
					msg = "[user] starts [head.disfigure ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [tool]."
					self_msg = "You start [head.disfigure ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [tool]."
			if(BP_HEAD)
			//brain chips
				var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
				if(BP.open == BP_SAW_INTERNALS_OPEN_STATE && brain?.status & ORGAN_BLEEDING)
					msg = "[user] starts taking bone chips out of [surgery_victim]'s brain with \the [tool]."
					self_msg = "You start taking bone chips out of [surgery_victim]'s brain with \the [tool]."

	surgery_victim.custom_pain(cp_msg, 1)
	user.visible_message(msg, self_msg)

	..()

/datum/surgery_step/clamp/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	if(BP.status & ORGAN_BLEEDING)
	//clamp bleeding
		msg = "<span class='notice'>[user] clamps bleeders in [surgery_victim]'s [BP.name] with \the [tool].</span>"
		self_msg = "<span class='notice'>You clamp bleeders in [surgery_victim]'s [BP.name] with \the [tool].</span>"
		BP.strap()
	else if(BP.stage & BP_KIT)
	//tissue
		msg = "<span class='notice'>[user] finishes connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [BP.name].</span>"
		self_msg = "<span class='notice'>[user] finish connecting regenerative membrane with damaged tissue inside of [surgery_victim]'s [BP.name].</span>"
		if(BP.trauma_kit)
			BP.trauma_kit = FALSE
			BP.heal_damage(20)
			BP.disinfect()
			BP.status &= ~ORGAN_BLEEDING
		if(BP.burn_kit)
			BP.burn_kit = FALSE
			BP.heal_damage(0, 20)
			BP.salve()
		BP.stage = 0
	else if(check_inside(BP))
	//implant remove
		if(length(BP.embedded_objects))
			var/list/list_of_embed_types = list()
			var/list/embed_object_shrapnel = list()
			var/list/embed_object_implants = list()
			var/list/embed_object_else = list()
			get_menu_of_embed(BP, embed_object_shrapnel, embed_object_implants, embed_object_else)
			var/list_to_choose = show_radial_menu(user, surgery_victim, list_of_embed_types, radius = 30, require_near = TRUE, tooltips = TRUE)
			if(!list_to_choose)
				user.visible_message("<span class='notice'>[user] removes \the [tool] from [surgery_victim]'s [BP.name].</span>", \
				"<span class='notice'>There's something inside [surgery_victim]'s [BP.name], but you decided not to touch it.</span>" )
				return FALSE
			switch(list_to_choose)
				if("Shrapnel")
					var/atom/picked_obj = pick(embed_object_shrapnel)
					remove_from_cavity(user, surgery_victim, picked_obj, BP, tool)
				if("Implants")
					var/choosen_object = show_radial_menu(user, surgery_victim, embed_object_implants, radius = 50, require_near = TRUE, tooltips = TRUE)
					if(choosen_object)
						var/obj/item/weapon/implant/imp = choosen_object
						imp.eject()
						remove_from_cavity(user, surgery_victim, choosen_object, BP, tool)
						surgery_victim.sec_hud_set_implants()
				if("Else")
					var/choosen_object = show_radial_menu(user, surgery_victim, embed_object_else, radius = 50, require_near = TRUE, tooltips = TRUE)
					if(choosen_object)
						if(isborer(choosen_object))
							var/mob/living/simple_animal/borer/worm = choosen_object
							if(worm.controlling)
								target.release_control()
							worm.detatch()
						if(isalienembryo(choosen_object))
						//alien reemove
							var/obj/item/alien_embryo/ae = choosen_object
							ae.detach()
						remove_from_cavity(user, surgery_victim, choosen_object, BP, tool)
			playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
		else if(BP.hidden)
			msg = "<span class='notice'>[user] takes something out of incision on [surgery_victim]'s [BP.name] with \the [tool].</span>"
			self_msg = "<span class='notice'>You take something out of incision on [surgery_victim]'s [BP.name]s with \the [tool].</span>"
			BP.hidden.forceMove(get_turf(surgery_victim))
			BP.hidden.item_actions_special = initial(BP.hidden.item_actions_special)
			BP.hidden.remove_item_actions(surgery_victim)
			if(!BP.hidden.blood_DNA)
				BP.hidden.blood_DNA = list()
			BP.hidden.blood_DNA[surgery_victim.dna.unique_enzymes] = surgery_victim.dna.b_type
			BP.hidden.update_icon()
			BP.hidden = null
	else
		var/obj/item/organ/external/head/head = BP
		switch(target_zone)
			if(O_EYES)
			//eyes
				var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
				msg = "<span class='notice'>[user] mends the nerves and lenses in [surgery_victim]'s with \the [tool].</span>"
				self_msg = "<span class='notice'>You mend the nerves and lenses in [surgery_victim]'s with \the [tool].</span>"

				surgery_victim.cure_nearsighted(list(EYE_DAMAGE_TRAIT, EYE_DAMAGE_TEMPORARY_TRAIT))
				surgery_victim.sdisabilities &= ~BLIND
				eyes.damage = 0
			if(O_MOUTH)
			//face && plastic surgery
				if(head.ps_status > NORMAL)
					msg = "<span class='notice'>[user] [head.disfigure ? "mending" : "adjusting"] [surgery_victim]'s vocal cords with \the [tool].</span>"
					self_msg = "<span class='notice'>You [head.disfigure ? "mending" : "adjusting"][surgery_victim]'s vocal cords with \the [tool].</span>"
					head.disfigure = FALSE
				head.ps_status = head.ps_status == CUTTED ? PREPARED : head.ps_status
			if(BP_HEAD)
				if(BP.open == BP_SAW_INTERNALS_OPEN_STATE)
				//brain chips
					msg = "<span class='notice'>[user] takes out all the bone chips in [surgery_victim]'s brain with \the [tool].</span>"
					self_msg = "<span class='notice'>You take out all the bone chips in [surgery_victim]'s brain with \the [tool].</span>"
					var/obj/item/organ/internal/brain/brain = surgery_victim:organs_by_name[O_BRAIN]
					brain.status &= ~ORGAN_BLEEDING


	surgery_victim.custom_pain(cp_msg, 1)
	user.visible_message(msg, self_msg)


/datum/surgery_step/clamp/fail_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	//eyes
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, stabbing \the [tool] into [target]'s eye!</span>", \
	"<span class='warning'>Your hand slips, stabbing \the [tool] into [target]'s eye!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(5, 0)

	//face
	user.visible_message("<span class='warning'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
	target.losebreath += 10

	//plastic surgery
	user.visible_message("<span class='warning'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
	target.losebreath += 10


	//brain chips
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, jabbing \the [tool] in [target]'s brain!</span>",
	"<span class='warning'>Your hand slips, jabbing \the [tool] in [target]'s brain!</span>")
	BP.take_damage(30, 0, DAM_SHARP, tool)

	//clamp bleeding
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [BP.name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [BP.name] with \the [tool]!</span>",)
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

	//implant remove
		var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
	if (length(BP.embedded_objects))
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		var/obj/item/weapon/implant/imp = locate(/obj/item/weapon/implant) in BP.embedded_objects
		if (prob(fail_prob))
			user.visible_message("<span class='warning'>Внутри [CASE(BP, GENITIVE_CASE)] [target] что-то пищит!</span>")
			playsound(imp, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
			addtimer(CALLBACK(imp, TYPE_PROC_REF(/obj/item/weapon/implant, use_implant)), 3 SECONDS)

	//alien remove no?


	//tissue
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>")
	BP.burn_kit = FALSE
	BP.trauma_kit = FALSE
	BP.take_damage(5, 0, used_weapon = tool)
	BP.stage = 0

/datum/surgery_step/proc/remove_from_cavity(mob/user, mob/target, obj/obj_to_remove, obj/item/organ/external/BP, obj/tool)
	BP.embedded_objects -= obj_to_remove
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


/datum/surgery_step/proc/check_inside(obj/item/organ/external/BP)
	for(var/something in BP.contents)
		if(!isorgan(something))
			return TRUE
	return FALSE


/datum/surgery_step/proc/get_menu_of_embed(obj/item/organ/external/BP, list/embed_object_shrapnel, list/embed_object_implants, list/embed_object_else)

	for(var/embed_object in BP.embedded_objects)
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
