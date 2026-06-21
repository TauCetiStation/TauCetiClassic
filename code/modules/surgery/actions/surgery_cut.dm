/datum/surgery_step/cut
	allowed_qualities = list(
		QUALITY_CUTTING,
		QUALITY_SURG_CUTTING,
		QUALITY_SCREWING // for ipc, burn it
		)

	var/plastic_new_name = null
	can_infect = TRUE
	min_duration = 9 SECONDS
	max_duration = 11 SECONDS

/datum/surgery_step/cut/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)

/////////////////////////////////////
///       SLIME SURGERY CUT       ///
/////////////////////////////////////
//Must be first, to invoke ..() and check bodyparts
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
///       IPC SURGERY CUT         ///
/////////////////////////////////////
	if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		can_infect = FALSE
		switch(target_zone)
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				if(eyes.surgery_stage < PREPARED)
					return TRUE
			if(BP_CHEST)
				if(BP.open == BP_SECURITY_PANEL_OPEN && surgery_victim.has_brain() && target_zone == BP_CHEST)
					return TRUE

/////////////////////////////////////
///     ORGANIC SURGERY CUT       ///
/////////////////////////////////////
	else if(surgery_victim.species.flags[IS_PLANT])	// Dionea, Podkid
		if(target_zone == BP_CHEST && BP.open == BP_SAW_INTERNALS_OPEN_STATE)
			return TRUE
	else if(!surgery_victim.species.flags[TRAIT_NO_BLOOD]) // human, unathi, tajaran, skrell and etc
		if(!BP.is_robotic_part())
			switch(target_zone)
				if(O_EYES)
					var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
					if(eyes.surgery_stage < PREPARED)
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
	return FALSE

/datum/surgery_step/cut/prepare_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(target_zone == O_MOUTH && ishuman(target))
		var/mob/living/carbon/human/surgery_victim = target
		var/obj/item/organ/external/head/HP = surgery_victim.get_bodypart(target_zone)
		if(HP.ps_status == PREPARED)
			plastic_new_name = sanitize_name(input(user, "Choose new character's name:", "Changing") as text|null)
			return plastic_new_name && checks_for_surgery(target, user, clothless)
	return TRUE

/datum/surgery_step/cut/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		user.visible_message("[user] starts cutting through [slime]'s [slime.surgery_status == 1 ? "innards" : "flesh"] with \the [tool].",
		"You start cutting through [slime]'s [slime.surgery_status == 1 ? "innards" : "flesh"] with \the [tool].")

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		if(BP.is_stump())
			user.visible_message("[user] begins to reposition wires where [surgery_victim]'s [BP] used to be with \the [tool].",
			"You begin to reposition wires where [surgery_victim]'s [BP] used to be with \the [tool].")
		else if(BP.open == BP_SECURITY_PANEL_OPEN)
			user.visible_message("[user] starts cutting wires connecting [surgery_victim]'s posi-brain with \the [tool].",
			"You start cutting wires connecting [surgery_victim]'s posi-brain with \the [tool].")

		else if(target_zone == O_EYES)
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(eyes)
				user.visible_message("[user] [eyes.surgery_stage == NORMAL ? "begins to unscrew" : "is beginning to lock"] [surgery_victim]'s camera panels with \the [tool]." ,
				"You [eyes.surgery_stage == NORMAL ? "unscrew" : "are beginning to lock"] [surgery_victim]'s camera panels with \the [tool].")

	else if(!surgery_victim.species.flags[TRAIT_NO_BLOOD])
		surgery_victim.custom_pain("You feel a horrible pain as if from a sharp knife in your [BP.name]!",1)
		switch(target_zone)
			if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				user.visible_message("[user] starts the incision on [surgery_victim]'s [BP.name] with \the [tool].", \
				"You start the incision on [surgery_victim]'s [BP.name] with \the [tool].")
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				if(eyes)
					if(eyes.surgery_stage == NORMAL)
						user.visible_message("[user] starts to separate the corneas on [surgery_victim]'s eyes with \the [tool].", \
						"You start to separate the corneas on [surgery_victim]'s eyes with \the [tool].")
					else if(eyes.surgery_stage == PREPARED)
						user.visible_message("[user] starts disconnect eyes inside the incision on [surgery_victim]'s [BP.name] with \the [tool].", \
						"You start disconnect eyes inside the incision on [surgery_victim]'s [BP.name] with \the [tool]" )
			if(O_MOUTH)
				var/obj/item/organ/external/head/HP = BP
				if(HP.ps_status == NORMAL)
					user.visible_message("[user] starts to cut open [surgery_victim]'s face and neck with \the [tool].", \
					"You start to cut open [surgery_victim]'s face and neck with \the [tool].")
				else if(HP.ps_status == PREPARED)
					user.visible_message("[user] begins to alter [surgery_victim]'s appearance with \the [tool].", \
					"You begin to alter [surgery_victim]'s appearance with \the [tool].")

	..()

/datum/surgery_step/cut/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
/////////////////////////////////////
///       SLIME SURGERY CUT       ///
/////////////////////////////////////
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		user.visible_message("<span class='notice'>[user] cuts through [target]'s [slime.surgery_status == 1 ? "silky innards" : "flesh"] with \the [tool].</span>",
		"<span class='notice'>You cut through [target]'s [slime.surgery_status == 1 ? "silky innards" : "flesh"] with \the [tool], exposing the cores.</span>")
		switch(slime.surgery_status)
			if(NORMAL) // cut_flesh
				slime.surgery_status = CUTTED
				return
			if(CUTTED)
				slime.surgery_status = PREPARED
				return

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
/////////////////////////////////////
///       IPC SURGERY CUT         ///
/////////////////////////////////////
	if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		switch(target_zone)
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				switch(eyes.surgery_stage)
					if(NORMAL)
						user.visible_message("<span class='notice'>[user] unscrewed [surgery_victim]'s camera panels with \the [tool].</span>",
						"<span class='notice'>You unscrewed [surgery_victim]'s camera panels with \the [tool].</span>")
						eyes.surgery_stage = CUTTED
					if(PREPARED)
						surgery_victim.cure_nearsighted(EYE_DAMAGE_TRAIT)
						surgery_victim.sdisabilities &= ~BLIND
						eyes.damage = 0
						eyes.surgery_stage = NORMAL
					else
						user.visible_message("<span class='notice'>[user] locks [surgery_victim]'s camera panels with \the [tool].</span>",
						"<span class='notice'>You lock [surgery_victim]'s camera panels with \the [tool].</span>")
				if(!surgery_victim.is_bruised_organ(O_KIDNEYS))
					to_chat(surgery_victim, "<span class='warning italics'>%VISUALS DENIED%. REQUESTING ADDITIONAL PERSPECTION REACTIONS.</span>")
				surgery_victim.blinded += 1.5
			if(BP_CHEST)
				switch(BP.open)
					if(BP_SECURITY_PANEL_OPEN)
						user.visible_message("<span class='notice'>[user] pries out [surgery_victim]'s posi-brain from \his hatch with \the [tool].</span>",
							"<span class='notice'>You pry out [surgery_victim]'s posi-brain from hatch with \the [tool].</span>")

						surgery_victim.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")

						var/brain_type = /obj/item/device/mmi/posibrain
						var/brain_species = surgery_victim.get_species()

						if(istype(BP, /obj/item/organ/external/chest/robot/ipc))
							var/obj/item/organ/external/chest/robot/ipc/I = BP
							brain_type = I.posibrain_type
							brain_species = I.posibrain_species

						var/obj/item/device/mmi/P = new brain_type(surgery_victim.loc)
						if(brain_species == DIONA)
							var/mob/living/carbon/monkey/diona/D = new(surgery_victim)

							D.real_name = surgery_victim.real_name
							D.name = surgery_victim.real_name

							D.dna = surgery_victim.dna.Clone()
							D.dna.SetSEState(MONKEYBLOCK, 1)
							D.dna.SetSEValueRange(MONKEYBLOCK, 0xDAC, 0xFFF)

							if(surgery_victim.mind)
								surgery_victim.mind.transfer_to(D)

							for(var/datum/language/L as anything in surgery_victim.languages)
								D.add_language(L.name, surgery_victim.languages[L])

							for(var/datum/quirk/Q in surgery_victim.roundstart_quirks)
								D.saved_quirks += Q.type

							P.transfer_nymph(D)
						else
							P.transfer_identity(surgery_victim)
						surgery_victim.death()

/////////////////////////////////////
///     ORGANIC SURGERY CUT       ///
/////////////////////////////////////
	if(surgery_victim.species.flags[IS_PLANT])
		switch(target_zone)
			if(BP_CHEST)
				switch(BP.open)
					if(BP_SAW_INTERNALS_OPEN_STATE)
						detach_brain(user, surgery_victim, tool)
	else if(!surgery_victim.species.flags[TRAIT_NO_BLOOD])
		switch(target_zone)
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				if(eyes)
					switch(eyes.surgery_stage)
						if(NORMAL)
							user.visible_message("<span class='notice'>[user] has separated the corneas on [surgery_victim]'s eyes with \the [tool].</span>" , \
							"<span class='notice'>You have separated the corneas on [surgery_victim]'s eyes with \the [tool].</span>",)
							eyes.surgery_stage = CUTTED
						if(PREPARED)
							eyes.status |= ORGAN_CUT_AWAY
							eyes.remove(surgery_victim)
							eyes.loc = get_turf(surgery_victim)
							BP.bodypart_organs  -= eyes
							playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
					surgery_victim.custom_pain("The pain in your head is living hell!",1)
					surgery_victim.blinded += 1.5
					return TRUE
				else
					user.visible_message("<span class='notice'>[user] could not find anything inside [surgery_victim]'s [BP.name], and pulls \the [tool] out.</span>", \
						"<span class='notice'>You could not find anything inside [surgery_victim]'s [BP.name].</span>")
					return FALSE
			if(O_MOUTH)
				var/obj/item/organ/external/head/HP = BP
				switch(HP.ps_status)
					if(NORMAL)
						user.visible_message("<span class='notice'>[user] has cut open [surgery_victim]'s face and neck with \the [tool].</span>" , \
						"<span class='notice'>You have cut open [surgery_victim]'s face and neck with \the [tool].</span>",)
						HP.ps_status = CUTTED
						return TRUE
					if(PREPARED)
						user.visible_message("<span class='notice'>[user] alters [surgery_victim]'s appearance with \the [tool].</span>",		\
						"<span class='notice'>You alter [surgery_victim]'s appearance with \the [tool].</span>")
						surgery_victim.real_name = plastic_new_name
						plastic_new_name = null
						return TRUE
			if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				switch(BP.open)
					if(BP_DEFAULT_STATE)
						var/datum/reagents/R = surgery_victim.reagents
						if(!R.has_reagent("metatrombine") || tool.damtype != BURN)
							BP.status |= ORGAN_BLEEDING
						user.visible_message("<span class='notice'>[user] has made a [BP.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [BP.name] with \the [tool].</span>", \
											"<span class='notice'>You have made a [BP.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [BP.name] with \the [tool].</span>",)

						BP.open = BP_SCALPEL_OPEN_STATE
						BP.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)
						BP.strap() // we dont apply ORGAN_BLEEDING early, and idn, need we this or not on case
						return TRUE
					if(BP_SAW_INTERNALS_OPEN_STATE)
						if(!length(BP.bodypart_organs))
							user.visible_message("<span class='notice'>[user] could not find anything inside [surgery_victim]'s [BP.name], and pulls \the [tool] out.</span>", \
													"<span class='notice'>You could not find anything inside [surgery_victim]'s [BP.name].</span>" )
							return FALSE
						else
							switch(target_zone)
								if(BP_HEAD)
									user.visible_message("<span class='notice'>[user] separates [surgery_victim]'s brain from \his spine with \the [tool].</span>",
									"<span class='notice'>You separate [surgery_victim]'s brain from spine with \the [tool].</span>")
									detach_brain(user, surgery_victim, tool)
									return TRUE

								if(BP_CHEST, BP_GROIN)
									var/list/organs_list = list()
									for(var/atom/embed_organ in BP.bodypart_organs)
										organs_list[embed_organ] = embed_organ.appearance
									var/choosen_organ = show_radial_menu(user, surgery_victim, organs_list, radius = 50, require_near = TRUE, tooltips = TRUE)
									if(!choosen_organ)
										user.visible_message("<span class='notice'>[user] could not find anything inside [surgery_victim]'s [BP.name], and pulls \the [tool] out.</span>", \
										"<span class='notice'>You could not find anything inside [surgery_victim]'s [BP.name].</span>")
										return FALSE
									var/obj/item/organ/internal/IO = choosen_organ
									IO.status |= ORGAN_CUT_AWAY
									IO.remove(surgery_victim)
									IO.loc = get_turf(surgery_victim)
									BP.bodypart_organs  -= IO
									playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
									return TRUE
	return FALSE

/datum/surgery_step/cut/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing [slime]'s [slime.surgery_status == 1 ? "innards" : "flesh"] with \the [tool]!</span>",
								 "<span class='warning'>Your hand slips, tearing [slime]'s [slime.surgery_status == 1 ? "innards" : "flesh"] with \the [tool]!</span>")
		return TRUE

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)

	if(surgery_victim.species.flags[IS_SYNTHETIC])
		if(target_zone == O_EYES)
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			user.visible_message("<span class='warning'>[user]'s hand slips, [eyes.surgery_stage != NORMAL ? "denting": "scratching"] [surgery_victim]'s cameras with \the [tool]!</span>",
			"<span class='warning'>Your hand slips, [eyes.surgery_stage != NORMAL ? "denting": "scratching"] [surgery_victim]'s cameras with \the [tool]!</span>")
			BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)
			eyes.take_damage(5, 0)
		else
			user.visible_message("<span class='warning'>[user]'s hand slips, severely denting [surgery_victim]'s posi-brain with \the [tool]!</span>",
			"<span class='warning'>Your hand slips, severely denting [surgery_victim]'s posi-brain with \the [tool]!</span>")
			BP.take_damage(30, 0, DAM_SHARP, tool)
		return TRUE

	switch(target_zone)
		if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [surgery_victim]'s [BP.name] in the wrong place with \the [tool]!</span>", \
			"<span class='warning'>Your hand slips, slicing open [surgery_victim]'s [BP.name] in the wrong place with \the [tool]!</span>")
			if(tool.damtype != BURN)
				BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
			else
				BP.take_damage(7.5, 12.5, DAM_SHARP|DAM_EDGE, tool)
			return TRUE
		if(O_EYES)
			var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing [surgery_victim]'s eyes wth \the [tool]!</span>" , \
			"<span class='warning'>Your hand slips, slicing [surgery_victim]'s eyes wth \the [tool]!</span>" )
			BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
			eyes.take_damage(5, 0)
			return TRUE
		if(O_MOUTH)
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing [surgery_victim]'s throat wth \the [tool]!</span>" , \
			"<span class='warning'>Your hand slips, slicing [surgery_victim]'s throat wth \the [tool]!</span>" )
			BP.take_damage(60, 0, DAM_SHARP|DAM_EDGE, tool)
			surgery_victim.losebreath += 10
	return FALSE

/datum/surgery_step/cut/proc/detach_brain(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/tool)
	var/mob/living/simple_animal/borer/borer = surgery_victim.has_brain_worms()
	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR
	surgery_victim.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")
	SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, surgery_victim)
	var/obj/item/organ/internal/brain/IO = surgery_victim.organs_by_name[O_BRAIN]
	IO.status |= ORGAN_CUT_AWAY
	IO.remove(surgery_victim)
	IO.loc = get_turf(surgery_victim)
	surgery_victim.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.
