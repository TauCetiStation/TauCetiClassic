// Input Sortcut Defines

// Slime action
#define SLIME_CUT_ACTION          "cut through [slime]'s [slime.surgery_status == CUTTED ? "silky innards" : "flesh"] with \the [tool]"

// Default cut|screw action
#define CUT_SCREW                 (bodypart.open == BP_DEFAULT_OS || (surgery_victim.species.flags[IS_SYNTHETIC] && bodypart.open == BP_SCALPEL_OS))
#define SCREWING_ACTION            "[bodypart.is_stump() ? "reposition wires where [surgery_victim]'s [bodypart] used to be with \the [tool]" : [bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [tool]]"
#define CUT_ACTION                 "[bodypart.is_stump() ? "cut away flesh on [surgery_victim]'s [bodypart.name] used to be with \the [tool]." : "make the incision on [surgery_victim]'s [bodypart.name] with \the [tool]"]"
#define SIMPLE_CUT_SCREW_ACTION    "[bodypart.controller.bodypart_type == BODYPART_ROBOTIC ? SCREWING_ACTION : CUT_ACTION]"

// Detach internal organ\brain
#define CUT_ORGAN                 (bodypart.open == BP_RIBCAGE_OS)
#define CUT_ORGAN_ACTION          "poking around inside the incision on [surgery_victim]'s [BP.name] with \the [tool]"

// Eyes action
#define EYES_SURGERY              (eyes?.surgery_stage <= BP_SCALPEL_OS)
#define MACHINE_EYES_SCREW_ACTION "[eyes.surgery_stage == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s camera panels with \the [tool]]"
#define ORGANIC_EYES_CUT_ACTION   "[eyes.surgery_stage == BP_DEFAULT_OS ? "separate" : "extract"] eyes from [surgery_victim]'s eyelid with \the [tool]"
#define SIMPLE_EYES_ACTION        "[eyes.status == ORGAN_ROBOT ? MACHINE_EYES_SCREW_ACTION : ORGANIC_EYES_CUT_ACTION]"

// Mouth Action
#define MOUTH_SURGERY            (head.ps_status == BP_DEFAULT_OS || head.ps_status == BP_INTERNALS_OS)
#define MACHINE_MOUTH_CUT_ACTION "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s screen with \the [tool]"
#define ORGANIC_MOUTH_CUT_ACTION "[head.ps_status == BP_DEFAULT_OS ? "cut open [surgery_victim]'s face and neck with \the [tool]" : "to alter [surgery_victim]'s appearance with \the [tool]"]"
#define SIMPLE_MOUTH_ACTION      "[surgery_victim.species.flags[IS_SYNTHETIC] ? MACHINE_MOUTH_CUT_ACTION : ORGANIC_MOUTH_CUT_ACTION]"

// Diona nymph extract action
#define NYMPH_SURGERY            (surgery_victim.get_species() == DIONA && target_zone == BP_CHEST && bodypart.open == BP_RIBCAGE_OS)
#define NYMPH_EXTRACT_ACTION     "separating connections roots to [surgery_victim]'s nymph with \the [tool]"

// Fatass remove action
#define FATASS_SURGERY           (bodypart.body_zone == BP_CHEST && surgery_victim.overeatduration > 0 && bodypart.open == BP_SCALPEL_OS)
#define FATASS_ACTION            ""

// Organics gender bender
#define GENDER_SURGERY           (target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && !surgery_victim.species.flags[TRAIT_NO_BLOOD] && surgery_victim.get_species() != VOX)
#define GENDER_BENDER_ACTION     "reshape [surgery_victim]'s genitals to look more [surgery_victim.gender == FEMALE ? "masculine" : "feminine" ] with \the [tool]"

// Machine Detach Positron Unit Action
#define DETACH_POSITRON          (target_zone == BP_CHEST && bodyprat.open == BP_RIBCAGE_OS && surgery_victim.has_brain() && surgery_victim.get_species() == IPC)
#define DETACH_POSITRON_ACTION   "detach wires on [surgery_victim]'s [bodypart.name] connected to positron brain unit with \the [tool]."

//Action
/datum/surgery_step/cut
	allowed_qualities = list(
		QUALITY_SURG_CUTTING,
		QUALITY_SCREWING // for ipc, burn it
		)

	allowed_species = null
	var/plastic_new_name = null
	can_infect = TRUE
	min_duration = 9 SECONDS
	max_duration = 11 SECONDS

/datum/surgery_step/cut/prepare_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(target_zone == O_MOUTH && ishuman(target) && !ismachine(target))
	//plastic surgery
		var/mob/living/carbon/human/surgery_victim = target
		var/obj/item/organ/external/head/head = surgery_victim.get_bodypart(target_zone)
		if(head.ps_status == BP_INTERNALS_OS)
			plastic_new_name = sanitize_name(input(user, "Choose new character's name:", "Changing") as text|null)
			return plastic_new_name && checks_for_surgery(target, user, clothless)
	return TRUE

/datum/surgery_step/cut/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
//Must be first, to invoke ..() and check bodyparts
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		if(slime.stat == DEAD && slime.surgery_status != PREPARED)
			msg = "[user] being [SLIME_CUT_ACTION]."
			self_msg = "You start [SLIME_CUT_ACTION]."
			user.visible_message(msg, self_msg)
			return TRUE

	if(!..())
		return FALSE

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(NYMPH_SURGERY)
	// Exception for Dionea
		msg = "[user] being to [NYMPH_EXTRACT_ACTION]."
		self_msg = "You start to [NYMPH_EXTRACT_ACTION]."
		user.visible_message(msg, self_msg)
		return TRUE
	if(DETACH_POSITRON)
	// IPC exception for detach brain
		msg = "[user] being to [DETACH_POSITRON_ACTION]"
		self_msg = "You start to [DETACH_POSITRON_ACTION]"
		user.visible_message(msg, self_msg)
		return TRUE

	switch(target_zone)
		if(O_EYES)
		// Cut|Screw Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(EYES_SURGERY)
				msg = "[user] are beginning to [SIMPLE_EYES_ACTION]"
				self_msg = "You are starting to [SIMPLE_EYES_ACTION]"
				user.visible_message(msg, self_msg)
				return TRUE
		if(O_MOUTH)
		// Cut|Screw Face
			var/obj/item/organ/external/head/head = bodypart
			if(MOUTH_SURGERY)
			//start operate face|plastic surgery
				msg = "[user] being to [SIMPLE_MOUTH_ACTION]."
				self_msg = "You start to [SIMPLE_MOUTH_ACTION]."
				user.visible_message(msg, self_msg)
				return TRUE
		else
		// Head, Chest, Groin, L|R Arm, L|R Leg
			if(GENDER_SURGERY)
			//gender surgery, in this stage we need check only VOX
				msg = "[user] begins to [GENDER_BENDER_ACTION]."
				self_msg = "You start to [GENDER_BENDER_ACTION]."
				cp_msg = "The pain in your groin is living hell!"
				user.visible_message(msg, self_msg)
				surgery_victim.custom_pain(cp_msg, 1)
				return TRUE
			if(CUT_ORGAN)
				msg = "[user] being [CUT_ORGAN_ACTION]"
				self_msg = "You start [CUT_ORGAN_ACTION]"
				cp_msg = "The pain in your chest is living hell!"
				user.visible_message(msg, self_msg)
				surgery_victim.custom_pain(cp_msg, 1)
			if(CUT_SCREW)
			// Cut|Screw Default|Limb cut replace stump to health part
				msg = "[user] being to [SIMPLE_CUT_SCREW_ACTION]"
				self_msg = "You start to [SIMPLE_CUT_SCREW_ACTION]"
				cp_msg = "You feel a horrible pain as if from a sharp knife in your [bodypart.name]!"
				user.visible_message(msg, self_msg)
				return TRUE

	return FALSE // if we can`t do this operation

/datum/surgery_step/cut/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		msg = "<span class='notice'>[user] finish [SLIME_CUT_ACTION].</span>"
		self_msg = "<span class='notice'>You finish [SLIME_CUT_ACTION], exposing the cores.</span>"
		switch(slime.surgery_status)
			if(NORMAL)
			// cut flesh
				slime.surgery_status = CUTTED
				return
			if(CUTTED)
			// cut internals flesh
				slime.surgery_status = PREPARED
				return

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		switch(target_zone)
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				switch(eyes.surgery_stage)
					if(BP_DEFAULT_OS)
						user.visible_message("<span class='notice'>[user] unscrewed [surgery_victim]'s camera panels with \the [tool].</span>",
						"<span class='notice'>You unscrewed [surgery_victim]'s camera panels with \the [tool].</span>")
						eyes.surgery_stage = BP_SCALPEL_OS
					if(BP_MAINTANCE_PO)
						surgery_victim.cure_nearsighted(EYE_DAMAGE_TRAIT)
						surgery_victim.sdisabilities &= ~BLIND
						eyes.damage = 0
						eyes.surgery_stage = BP_DEFAULT_OS
					else
						user.visible_message("<span class='notice'>[user] locks [surgery_victim]'s camera panels with \the [tool].</span>",
						"<span class='notice'>You lock [surgery_victim]'s camera panels with \the [tool].</span>")
				if(!surgery_victim.is_bruised_organ(O_KIDNEYS))
					to_chat(surgery_victim, "<span class='warning italics'>%VISUALS DENIED%. REQUESTING ADDITIONAL PERSPECTION REACTIONS.</span>")
				surgery_victim.blinded += 1.5
			if(O_MOUTH, BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				switch(bodypart.open)
					if(BP_MAINTANCE_PO)
						user.visible_message("<span class='notice'>[user] pries out [surgery_victim]'s posi-brain from \his hatch with \the [tool].</span>",
							"<span class='notice'>You pry out [surgery_victim]'s posi-brain from hatch with \the [tool].</span>")

						surgery_victim.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")

						var/brain_type = /obj/item/device/mmi/posibrain
						var/brain_species = surgery_victim.get_species()

						if(istype(bodypart, /obj/item/organ/external/chest/robot/ipc))
							var/obj/item/organ/external/chest/robot/ipc/I = bodypart
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
					if(BP_DEFAULT_OS) // open shut
						user.visible_message("<span class='notice'>[user] has loosen bolts on [surgery_victim]'s [bodypart.name]'s [target_zone != O_MOUTH ? "maintenance hatch" : "screen"] with \the [tool].</span>",
						"<span class='notice'>You have unscrewed [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [tool].</span>",)
						bodypart.open = BP_UNLOCK_P
						bodypart.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)
						return TRUE
					if(BP_UNLOCK_P) // close shut
						user.visible_message("<span class='notice'>[user] locks [surgery_victim]'s [bodypart.name]'s [target_zone != O_MOUTH ? "maintenance hatch" : "screen"] with \the [tool].</span>",
						"<span class='notice'>You lock [surgery_victim]'s [bodypart.name]'s [target_zone != O_MOUTH ? "maintenance hatch" : "screen"] with \the [tool].</span>")
						bodypart.open = BP_DEFAULT_OS
						return TRUE

	if(surgery_victim.species.flags[IS_PLANT])
		switch(target_zone)
			if(BP_CHEST)
				switch(bodypart.open)
					if(BP_INTERNALS_OS)
						user.visible_message("<span class='notice'>[user] separates connections to [surgery_victim]'s brain with \the [tool].</span>",
						"<span class='notice'>You separate connections to [surgery_victim]'s brain with \the [tool].</span>")
						detach_brain(user, surgery_victim, tool)
	else if(!surgery_victim.species.flags[TRAIT_NO_BLOOD])
		switch(target_zone)
			if(O_EYES)
				var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
				if(eyes)
					switch(eyes.surgery_stage)
						if(BP_DEFAULT_OS)
							user.visible_message("<span class='notice'>[user] has separated the corneas on [surgery_victim]'s eyes with \the [tool].</span>" , \
							"<span class='notice'>You have separated the corneas on [surgery_victim]'s eyes with \the [tool].</span>",)
							eyes.surgery_stage = BP_SCALPEL_OS
						if(BP_INTERNALS_OS)
							eyes.status |= ORGAN_CUT_AWAY
							eyes.remove(surgery_victim)
							eyes.loc = get_turf(surgery_victim)
							bodypart.bodypart_organs  -= eyes
							playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
					surgery_victim.custom_pain("The pain in your head is living hell!",1)
					surgery_victim.blinded += 1.5
					return TRUE
				else
					user.visible_message("<span class='notice'>[user] could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [tool] out.</span>", \
						"<span class='notice'>You could not find anything inside [surgery_victim]'s [bodypart.name].</span>")
					return FALSE
			if(O_MOUTH)
				var/obj/item/organ/external/head/head = bodypart
				switch(head.ps_status)
					if(BP_DEFAULT_OS)
						user.visible_message("<span class='notice'>[user] has cut open [surgery_victim]'s face and neck with \the [tool].</span>" , \
						"<span class='notice'>You have cut open [surgery_victim]'s face and neck with \the [tool].</span>",)
						head.ps_status = BP_SCALPEL_OS
						return TRUE
					if(BP_INTERNALS_OS)
						user.visible_message("<span class='notice'>[user] alters [surgery_victim]'s appearance with \the [tool].</span>",		\
						"<span class='notice'>You alter [surgery_victim]'s appearance with \the [tool].</span>")
						surgery_victim.real_name = plastic_new_name
						plastic_new_name = null
						head.ps_status = BP_DEFAULT_OS
						return TRUE
			if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
				if(target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && surgery_victim.get_species() != VOX) // in this stage we need check only VOX
					user.visible_message("<span class='notice'>[user] has made a [surgery_victim.gender == FEMALE ? "man" : "woman"] of [surgery_victim] with \the [tool].</span>" , \
					"<span class='notice'>You have made a [surgery_victim.gender == FEMALE ? "man" : "woman"] of [target].</span>")
					target.gender = target.gender == MALE ? FEMALE : MALE
					surgery_victim.regenerate_icons()
				switch(bodypart.open)
					if(BP_DEFAULT_OS)
						var/datum/reagents/R = surgery_victim.reagents
						if(!R.has_reagent("metatrombine") || tool.damtype != BURN)
							bodypart.status |= ORGAN_BLEEDING
						user.visible_message("<span class='notice'>[user] has made a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [tool].</span>", \
											"<span class='notice'>You have made a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [tool].</span>",)

						bodypart.open = BP_SCALPEL_OS
						bodypart.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)
						return TRUE
					if(BP_INTERNALS_OS)
						if(!length(bodypart.bodypart_organs))
							user.visible_message("<span class='notice'>[user] could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [tool] out.</span>", \
													"<span class='notice'>You could not find anything inside [surgery_victim]'s [bodypart.name].</span>" )
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
									for(var/atom/embed_organ in bodypart.bodypart_organs)
										organs_list[embed_organ] = embed_organ.appearance
									var/choosen_organ = show_radial_menu(user, surgery_victim, organs_list, radius = 50, require_near = TRUE, tooltips = TRUE)
									if(!choosen_organ)
										user.visible_message("<span class='notice'>[user] could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [tool] out.</span>", \
										"<span class='notice'>You could not find anything inside [surgery_victim]'s [bodypart.name].</span>")
										return FALSE
									var/obj/item/organ/internal/IO = choosen_organ
									IO.status |= ORGAN_CUT_AWAY
									IO.remove(surgery_victim)
									IO.loc = get_turf(surgery_victim)
									bodypart.bodypart_organs  -= IO
									playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
									return TRUE
	return FALSE

/datum/surgery_step/cut/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing [slime]'s [slime.surgery_status == CUTTED ? "innards" : "flesh"] with \the [tool]!</span>",
								 "<span class='warning'>Your hand slips, tearing [slime]'s [slime.surgery_status == CUTTED ? "innards" : "flesh"] with \the [tool]!</span>")
		return TRUE

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(surgery_victim.species.flags[IS_SYNTHETIC])
		if(target_zone == O_EYES)
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			user.visible_message("<span class='warning'>[user]'s hand slips, [eyes.surgery_stage != BP_SCALPEL_OS ? "denting": "scratching"] [surgery_victim]'s cameras with \the [tool]!</span>",
			"<span class='warning'>Your hand slips, [eyes.surgery_stage != BP_SCALPEL_OS ? "denting": "scratching"] [surgery_victim]'s cameras with \the [tool]!</span>")
			bodypart.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)
			eyes.take_damage(5, 0)
			return TRUE
		switch(bodypart.open)
			if(BP_MAINTANCE_PO)
				user.visible_message("<span class='warning'>[user]'s hand slips, severely denting [surgery_victim]'s posi-brain with \the [tool]!</span>",
				"<span class='warning'>Your hand slips, severely denting [surgery_victim]'s posi-brain with \the [tool]!</span>")
				bodypart.take_damage(30, 0, DAM_SHARP, tool)
				return TRUE
			if(BP_DEFAULT_OS, BP_UNLOCK_P)
				user.visible_message("<span class='warning'>[user]'s hand slips, [bodypart.open == BP_DEFAULT_OS ? "scratching" : "denting"] [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [tool]!</span>",
				"<span class='warning'>Your hand slips, [bodypart.open == BP_DEFAULT_OS ? "scratching" : "denting"] [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [tool]!</span>")
				bodypart.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
				return TRUE

	switch(target_zone)
		if(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_LEG, BP_R_ARM, BP_R_LEG)
			if(target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && surgery_victim.get_species() != VOX) // in this stage we need check only VOX
				user.visible_message("<span class='warning'>[user]'s hand slips, slicing [surgery_victim]'s genitals with \the [tool]!</span>", \
				"<span class='warning'>Your hand slips, slicing [surgery_victim]'s genitals with \the [tool]!</span>")
				if(tool.damtype != BURN)
					bodypart.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
				else
					bodypart.take_damage(5, 15, DAM_SHARP|DAM_EDGE, tool)
			if(bodypart.open == BP_INTERNALS_OS)
				user.visible_message("<span class='warning'>[user]'s hand slips, cutting a [surgery_victim]'s vein on organ with \the [tool]!</span>",
				"<span class='warning'>Your hand slips, cutting a [surgery_victim]'s vein on organ with \the [tool]!</span>")
				if(tool.damtype != BURN)
					bodypart.take_damage(50, 0, DAM_SHARP|DAM_EDGE, tool)
				else
					bodypart.take_damage(15, 35, DAM_SHARP|DAM_EDGE, tool)
			else
				user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [surgery_victim]'s [bodypart.name] in the wrong place with \the [tool]!</span>", \
				"<span class='warning'>Your hand slips, slicing open [surgery_victim]'s [bodypart.name] in the wrong place with \the [tool]!</span>")
				if(tool.damtype != BURN)
					bodypart.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
				else
					bodypart.take_damage(7.5, 12.5, DAM_SHARP|DAM_EDGE, tool)
			return TRUE
		if(O_EYES)
			var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing [surgery_victim]'s eyes wth \the [tool]!</span>" , \
			"<span class='warning'>Your hand slips, slicing [surgery_victim]'s eyes wth \the [tool]!</span>" )
			bodypart.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
			eyes.take_damage(5, 0)
			return TRUE
		if(O_MOUTH)
			user.visible_message("<span class='warning'>[user]'s hand slips, slicing [surgery_victim]'s throat wth \the [tool]!</span>" , \
			"<span class='warning'>Your hand slips, slicing [surgery_victim]'s throat wth \the [tool]!</span>" )
			bodypart.take_damage(60, 0, DAM_SHARP|DAM_EDGE, tool)
			surgery_victim.losebreath += 10
	return FALSE

/datum/surgery_step/cut/proc/detach_brain(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/tool)
	var/mob/living/simple_animal/borer/borer = surgery_victim.has_brain_worms()
	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR
	surgery_victim.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")
	SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, surgery_victim)
	var/obj/item/organ/internal/brain/brain = surgery_victim.organs_by_name[O_BRAIN]
	brain.status |= ORGAN_CUT_AWAY
	brain.remove(surgery_victim)
	brain.loc = get_turf(surgery_victim)
	surgery_victim.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.


	switch(target_zone)
		if(O_EYES)
		// Cut|Screw Eyes
		if(O_MOUTH)
		// Cut|Screw Face

		else // Head, Chest, Groin, L|R Arm, L|R Leg
			if(bodypart.open == BP_DEFAULT_OS)
			// Cut|Screw Default
