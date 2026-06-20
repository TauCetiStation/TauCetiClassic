/datum/surgery_step/cut
	allowed_qualities = list(
		QUALITY_CUTTING,
		QUALITY_SURG_CUTTING
		)

	can_infect = TRUE

	min_duration = 9 SECONDS
	max_duration = 11 SECONDS

/datum/surgery_step/cut/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)

/////////////////////////////////////
///     SLIME SURGERY CUT         ///
/////////////////////////////////////
//Must be first, to invoke ..()

	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		if(slime.stat == DEAD && slime.surgery_status != PREPARED)
			return TRUE

	var/mob/living/carbon/human/surgery_victim = target
	if(!..())
		return FALSE


	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)

	if(BP.is_stump()) 				// stump preparing
		return TRUE					// prevert etc checks, is target bodypart is stump

/////////////////////////////////////
///     ORGANIC SURGERY CUT       ///
/////////////////////////////////////

	if(!surgery_victim.species.flags[TRAIT_NO_BLOOD]) // human, unathi, tajaran, skrell and etc
		switch(target_zone)
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				if(eyes.surgery_stage & (IO_NORMAL_STATE | IO_ORGAN_CUTTED))
					return TRUE
			if(O_MOUTH)
				var/obj/item/organ/external/head/head = BP
				if(head.ps_status < PREPARED)
					return TRUE
			if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				switch(BP.open)
					if(BP_DEFAULT_STATE)						// open part
						return TRUE
					if(BP_SCALPEL_OPEN_STATE)
						if(BP.body_zone == BP_CHEST\
						&& surgery_victim.overeatduration > 0) // Fat surgery
							return TRUE
					if(BP_RETRACTOR_OPEN_STATE)
						if(BP.body_zone == BP_GROIN)		// detach internal organs from groin
							return TRUE
					if(BP_SAW_INTERNALS_OPEN_STATE)			// detach internal organs from head or chest
						if(BP.body_zone == BP_HEAD\
						 ||BP.body_zone == BP_CHEST)
							return TRUE

/////////////////////////////////////
///       IPC SURGERY CUT         ///
/////////////////////////////////////
	else if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		can_infect = FALSE
		if(target_zone == BP_CHEST && BP.open == BP_SECURITY_PANEL_OPEN)
			return TRUE
	else				// Dionea, Podkid
		if(target_zone == BP_CHEST && BP.open == BP_SAW_INTERNALS_OPEN_STATE)
			return TRUE

	return FALSE

/datum/surgery_step/cut/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return FALSE

/datum/surgery_step/cut/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target

	var/mob/living/carbon/human/H = target

	switch(target_zone)
		if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
			var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
			user.visible_message("[user] starts the incision on [H]'s [BP.name] with \the [tool].", \
			"You start the incision on [H]'s [BP.name] with \the [tool].")
			H.custom_pain("You feel a horrible pain as if from a sharp knife in your [BP.name]!",1)
		if(O_EYES)
			user.visible_message("[user] starts to separate the corneas on [H]'s eyes with \the [tool].", \
								"You start to separate the corneas on [H]'s eyes with \the [tool].")
	..()

/datum/surgery_step/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	switch(target_zone)
		if(O_EYES)
			user.visible_message("<span class='notice'>[user] has separated the corneas on [target]'s eyes with \the [tool].</span>" , \
			"<span class='notice'>You have separated the corneas on [target]'s eyes with \the [tool].</span>",)
			target.op_stage.eyes = 1
			target.blinded += 1.5
		if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
			var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
			if(BP.open == BP_DEFAULT_STATE)
				var/datum/reagents/R = target.reagents
				if(!R.has_reagent("metatrombine") || tool.damtype != BURN)
					BP.status |= ORGAN_BLEEDING
				user.visible_message("<span class='notice'>[user] has made a [BP.status & ORGAN_BLEEDING ? null : "bloodless"] incision on [target]'s [BP.name] with \the [tool].</span>", \
									"<span class='notice'>You have made a [BP.status & ORGAN_BLEEDING ? null : "bloodless"] incision on [target]'s [BP.name] with \the [tool].</span>",)

				BP.open = BP_SCALPEL_OPEN_STATE
				BP.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)
				BP.strap() // we dont apply ORGAN_BLEEDING early, and idn, need we this or not on case
			if(BP.open == BP_SAW_INTERNALS_OPEN_STATE)
				if(!length(BP.bodypart_organs))
					user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
											"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>" )
					return FALSE
				else
					switch(target_zone)
						if(BP_HEAD)
							user.visible_message("<span class='notice'>[user] separates [target]'s brain from \his spine with \the [tool].</span>",
												 "<span class='notice'>You separate [target]'s brain from spine with \the [tool].</span>")
							var/mob/living/simple_animal/borer/borer = target.has_brain_worms()
							if(borer)
								borer.detatch() //Should remove borer if the brain is removed - RR
							target.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")
							SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, target)
							var/obj/item/organ/internal/brain/IO = target.organs_by_name[O_BRAIN]
							IO.status |= ORGAN_CUT_AWAY
							IO.remove(target)
							IO.loc = get_turf(target)
							target.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.
							return TRUE

						if(BP_CHEST, BP_GROIN)
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
							return TRUE


/datum/surgery_step/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	switch(target_zone)
		if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
			var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!</span>", \
			"<span class='warning'>Your hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!</span>")
			if(tool.damtype != BURN)
				BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
			else
				BP.take_damage(7.5, 12.5, DAM_SHARP|DAM_EDGE, tool)

		if(O_EYES)
			var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
			var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s eyes wth \the [tool]!</span>" , \
			"<span class='warning'>Your hand slips, slicing [target]'s eyes wth \the [tool]!</span>" )
			BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
			IO.take_damage(5, 0)
