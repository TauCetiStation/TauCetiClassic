// Condition content
#define CUT_SCREW                 (bodypart.open == BP_DEFAULT_OS || (surgery_victim.species.flags[IS_SYNTHETIC] && bodypart.open == BP_SCALPEL_OS))
#define CUT_ORGAN                 (bodypart.open == BP_RIBCAGE_OS)
#define EYES_SURGERY              (eyes?.surgery_stage <= BP_SCALPEL_OS)
#define MOUTH_SURGERY             (head.ps_status == BP_DEFAULT_OS || head.ps_status == BP_RETRACT_OS)
#define PLASTIC_SURGERY           (target_zone == O_MOUTH && ishuman(target) && !ismachine(target))
#define GENDER_SURGERY            (target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && !surgery_victim.species.flags[TRAIT_NO_BLOOD] && surgery_victim.get_species() != VOX)

// Output Sortcut Defines
// Slime action
#define SLIME_CUT_ACTION          "cut through [slime]'s [slime.surgery_status == CUTTED ? "silky innards" : "flesh"] with \the [tool]"

// Default cut|screw action
#define SCREWING_ACTION            bodypart.is_stump() ? "reposition wires where [surgery_victim]'s [bodypart] used to be with \the [tool]" : "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [tool]"
#define CUT_ACTION                 bodypart.is_stump() ? "cut away flesh on [surgery_victim]'s [bodypart.name] used to be with \the [tool]." : "make a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [tool]"
#define SIMPLE_CUT_SCREW_ACTION    bodypart.controller.bodypart_type == BODYPART_ROBOTIC ? SCREWING_ACTION : CUT_ACTION

// Eyes action
#define MACHINE_EYES_SCREW_ACTION "[eyes.surgery_stage == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [eyes.name] panels with \the [tool]]"
#define ORGANIC_EYES_CUT_ACTION   "[eyes.surgery_stage == BP_DEFAULT_OS ? "separate" : "extract"] eyes from [surgery_victim]'s eyelid with \the [tool]"
#define SIMPLE_EYES_ACTION        "[eyes.status & ORGAN_ROBOT ? MACHINE_EYES_SCREW_ACTION : ORGANIC_EYES_CUT_ACTION]"

// Mouth Action
#define MACHINE_MOUTH_CUT_ACTION  "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s screen with \the [tool]"
#define ORGANIC_MOUTH_CUT_ACTION  "[head.ps_status == BP_DEFAULT_OS ? "cut open [surgery_victim]'s face and neck with \the [tool]" : "to alter [surgery_victim]'s appearance with \the [tool]"]"
#define SIMPLE_MOUTH_ACTION       "[bodypart.controller.bodypart_type == BODYPART_ROBOTIC ? MACHINE_MOUTH_CUT_ACTION : ORGANIC_MOUTH_CUT_ACTION]"

// Detach brain on organic IPC and plant
#define DETACH_BRAIN_ACTION       "separates [surgery_victim]'s brain from \his spine with \the [tool]"
#define NYMPH_EXTRACT_ACTION      "separating connections roots to [surgery_victim]'s nymph with \the [tool]"
#define DETACH_POSITRON_ACTION    "detach wires on [surgery_victim]'s [bodypart.name] connected to positron brain unit with \the [tool]."
#define SIMPLE_DETACH_ACTION      surgery_victim.get_species() == DIONA ? NYMPH_EXTRACT_ACTION : (surgery_victim.species.flags[IS_SYNTHETIC] ? DETACH_POSITRON_ACTION : DETACH_BRAIN_ACTION)

// Organics gender bender
#define GENDER_BENDER_ACTION      "reshape [surgery_victim]'s genitals to look more [surgery_victim.gender == FEMALE ? "masculine" : "feminine" ] with \the [tool]"

// Action
/datum/surgery_step/cut
	allowed_qualities = list(
		QUALITY_SURG_CUTTING,
		QUALITY_SCREWING // for ipc, burn it
		)

	allowed_species = null
	var/plastic_new_name = null
	min_duration = 9 SECONDS
	max_duration = 11 SECONDS

/datum/surgery_step/cut/prepare_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(PLASTIC_SURGERY)
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
				msg = "[user] being [POKING_ACTION]"
				self_msg = "You start [POKING_ACTION]"
				cp_msg = "The pain in your chest is living hell!"
				user.visible_message(msg, self_msg)
				surgery_victim.custom_pain(cp_msg, 1)
			if(CUT_SCREW)
			// Cut|Screw Default|Limb cut replace stump to health part
				var/datum/reagents/R = surgery_victim.reagents
				if(!R.has_reagent("metatrombine") || tool.damtype != BURN || !surgery_victim.species.flags[TRAIT_NO_BLOOD])
					bodypart.status |= ORGAN_BLEEDING

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
			if(CUTTED)
			// cut internals flesh
				slime.surgery_status = PREPARED
		user.visible_message(msg, self_msg)
		return

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	switch(target_zone)
		if(O_EYES)
		// Cut|Screw Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			msg = "[user] are finish to [SIMPLE_EYES_ACTION]"
			self_msg = "You are finish to [SIMPLE_EYES_ACTION]"
			cp_msg = "The pain in your head is living hell!"
			if(eyes)
				switch(eyes.surgery_stage)
					if(BP_DEFAULT_OS)
					//Cuts on Unscrew eyes
						eyes.surgery_stage = BP_SCALPEL_OS
					if(BP_SCALPEL_OS)
					//Screw eyes if robotic
						if(eyes.status & ORGAN_ROBOT)
							eyes.surgery_stage = BP_DEFAULT_OS
					if(BP_RETRACT_OS)
						eyes.status |= ORGAN_CUT_AWAY
						eyes.remove(surgery_victim)
						eyes.loc = get_turf(surgery_victim)
						bodypart.bodypart_organs  -= eyes
						playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
						surgery_victim.custom_pain(cp_msg, 1)
				surgery_victim.blinded += 1.5
			else
				msg = "[user] [NO_POKING_MESSAGE]."
				self_msg = "You [NO_POKING_MESSAGE]."
		if(O_MOUTH)
		// Cut|Screw Face
			var/obj/item/organ/external/head/head = bodypart
			msg = "[user] finish to [SIMPLE_MOUTH_ACTION]."
			self_msg = "You finish to [SIMPLE_MOUTH_ACTION]."

			switch(head.ps_status)
				if(BP_DEFAULT_OS)
					head.ps_status = BP_SCALPEL_OS
				if(BP_RETRACT_OS)
					if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
						head.ps_status = BP_DEFAULT_OS
				if(BP_INTERNALS_OS)
					surgery_victim.real_name = plastic_new_name
					plastic_new_name = null

		else // Head, Chest, Groin, L|R Arm, L|R Leg
			if(GENDER_SURGERY)
			// Gender surgery, in this stage we need check only VOX
				msg = "[user] finish to [GENDER_BENDER_ACTION]."
				self_msg = "You finish to [GENDER_BENDER_ACTION]."
				target.gender = target.gender == MALE ? FEMALE : MALE
				surgery_victim.regenerate_icons()
			if(CUT_ORGAN)
			// Detach organ or brain
				if(!length(bodypart.bodypart_organs))
					msg = "[user] [NO_POKING_MESSAGE]."
					self_msg = "You [NO_POKING_MESSAGE]."
					user.visible_message(msg, self_msg)
					return FALSE
				else
					msg = "You finish to [POKING_ACTION]."
					self_msg = "You finish to [POKING_ACTION]."
					var/list/organs_list = list()
					for(var/atom/embed_organ in bodypart.bodypart_organs)
						organs_list[embed_organ] = embed_organ.appearance
					var/choosen_organ = show_radial_menu(user, surgery_victim, organs_list, radius = 50, require_near = TRUE, tooltips = TRUE)
					if(!choosen_organ)
						msg = "[user] [NO_POKING_MESSAGE]."
						self_msg = "You [NO_POKING_MESSAGE]."
						user.visible_message(msg, self_msg)
						return FALSE
					var/obj/item/organ/internal/IO = choosen_organ
					if(isbrain(IO))
						prepare_to_detach_brain(user, surgery_victim, bodypart, tool)
						msg = "You finish to [SIMPLE_DETACH_ACTION]."
						self_msg = "You finish to [SIMPLE_DETACH_ACTION]."
					IO.status |= ORGAN_CUT_AWAY
					IO.remove(surgery_victim)
					IO.loc = get_turf(surgery_victim)
					bodypart.bodypart_organs  -= IO
					playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
			if(CUT_SCREW)
			// Cut|Screw Default
				msg = "[user] finish to [SIMPLE_CUT_SCREW_ACTION]"
				self_msg = "You finish to [SIMPLE_CUT_SCREW_ACTION]"
				cp_msg = "You feel a horrible pain as if from a sharp knife in your [bodypart.name]!"

				bodypart.open = (bodypart.open == BP_SCALPEL_OS && bodypart.controller.bodypart_type == BODYPART_ROBOTIC) ? BP_DEFAULT_OS : BP_SCALPEL_OS

	user.visible_message(msg, self_msg)

/datum/surgery_step/cut/proc/prepare_to_detach_brain(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/organ/external/bodypart, obj/item/tool)
	var/mob/living/simple_animal/borer/borer = surgery_victim.has_brain_worms()
	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR
	surgery_victim.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")
	SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, surgery_victim)
	if(surgery_victim.get_species() == IPC)
		var/obj/item/organ/external/chest/robot/ipc/ipc_chest = bodypart
		var/obj/item/device/mmi/mmi_positron = new ipc_chest.posibrain_type(surgery_victim.loc)
		if(ipc_chest.posibrain_species == DIONA)
			var/mob/living/carbon/monkey/diona/nymph = new(surgery_victim)
			nymph.real_name = surgery_victim.real_name
			nymph.name = surgery_victim.real_name
			nymph.dna = surgery_victim.dna.Clone()
			nymph.dna.SetSEState(MONKEYBLOCK, 1)
			nymph.dna.SetSEValueRange(MONKEYBLOCK, 0xDAC, 0xFFF)
			if(surgery_victim.mind)
				surgery_victim.mind.transfer_to(nymph)
			for(var/datum/language/L as anything in surgery_victim.languages)
				nymph.add_language(L.name, surgery_victim.languages[L])
			for(var/datum/quirk/Q in surgery_victim.roundstart_quirks)
				nymph.saved_quirks += Q.type
			mmi_positron.transfer_nymph(nymph)
		else
			mmi_positron.transfer_identity(surgery_victim)

	surgery_victim.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.
// Condition content
#undef CUT_SCREW
#undef CUT_ORGAN
#undef EYES_SURGERY
#undef MOUTH_SURGERY
#undef PLASTIC_SURGERY
#undef GENDER_SURGERY
#undef SLIME_CUT_ACTION
#undef SCREWING_ACTION
#undef CUT_ACTION
#undef SIMPLE_CUT_SCREW_ACTION
#undef MACHINE_EYES_SCREW_ACTION
#undef ORGANIC_EYES_CUT_ACTION
#undef SIMPLE_EYES_ACTION
#undef MACHINE_MOUTH_CUT_ACTION
#undef ORGANIC_MOUTH_CUT_ACTION
#undef SIMPLE_MOUTH_ACTION
#undef DETACH_BRAIN_ACTION
#undef NYMPH_EXTRACT_ACTION
#undef DETACH_POSITRON_ACTION
#undef SIMPLE_DETACH_ACTION
#undef GENDER_BENDER_ACTION
