/datum/surgery_step/cut
	name = "Cut"
	allowed_qualities = list(
		QUALITY_SURGERY_CUTTING,
		QUALITY_SCREWING // for ipc, burn it
		)

	allowed_species = null // allowed for all species
	var/plastic_new_name = null
	min_duration = 9 SECONDS
	max_duration = 11 SECONDS

/datum/surgery_step/cut/prepare_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/I)
	if(target_zone == O_MOUTH && ishuman(target) && !ismachine(target))
	//plastic surgery
		var/mob/living/carbon/human/surgery_victim = target
		var/obj/item/organ/external/head/head = surgery_victim.get_bodypart(target_zone)
		if(head.ps_status == BP_INTERNALS_OS)
			plastic_new_name = sanitize_name(input(user, "Choose new character's name:", "Changing") as text|null)
			return plastic_new_name && checks_for_surgery(target, user, clothless)
	return TRUE

/datum/surgery_step/cut/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/I)
//Must be first, to invoke ..() and check bodyparts
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		if(slime.stat == DEAD && slime.surgery_status != SLIME_SKIN_PREPARED)
			return TRUE

	if(!..())
		return FALSE

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	switch(target_zone)
		if(O_EYES)
		// Cut|Screw Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(eyes?.surgery_stage <= BP_SCALPEL_OS)
				return TRUE
		if(O_MOUTH)
		// Cut|Screw Face
			var/obj/item/organ/external/head/head = bodypart
			if(head.ps_status == BP_DEFAULT_OS || head.ps_status == BP_RETRACT_OS)
			//start operate face|plastic surgery
				return TRUE
		else
		// Head, Chest, Groin, L|R Arm, L|R Leg
			if(target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && !surgery_victim.species.flags[TRAIT_NO_BLOOD] && surgery_victim.get_species() != VOX)
			//gender surgery, in this stage we need check only VOX
				return TRUE
			if(bodypart.open == BP_RIBCAGE_OS)
				return TRUE
			if(bodypart.open == BP_DEFAULT_OS || (bodypart.controller.bodypart_type == BODYPART_ROBOTIC && bodypart.open == BP_SCALPEL_OS))
			// Cut|Screw Default|Limb cut replace stump to health part
				return TRUE

	return FALSE // if we can`t do this operation

/datum/surgery_step/cut/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	. = ..()
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		if(slime.stat == DEAD && slime.surgery_status != SLIME_SKIN_PREPARED)
			msg = "<span class='notice'>[user] begin cut through [slime]'s [slime.surgery_status == SLIME_SKIN_CUTTED ? "silky innards" : "flesh"] with \the [I].</span>"
			self_msg = "<span class='notice'>You start cut through [slime]'s [slime.surgery_status == SLIME_SKIN_CUTTED ? "silky innards" : "flesh"] with \the [I].</span>"
			user.visible_message(msg, self_msg)

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	switch(target_zone)
		if(O_EYES)
		// Cut|Screw Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(eyes?.surgery_stage <= BP_SCALPEL_OS)
				if(eyes.status & ORGAN_ROBOT)
					msg = "<span class='notice'>[user] are beginning to [eyes.surgery_stage == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [eyes.name] panels with \the [I]].</span>"
					self_msg = "<span class='notice'>You are starting to [eyes.surgery_stage == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [eyes.name] panels with \the [I]].</span>"
				else
					msg = "<span class='notice'>[user] are beginning to [eyes.surgery_stage == BP_DEFAULT_OS ? "separate" : "extract"] eyes from [surgery_victim]'s eyelid with \the [I].</span>"
					self_msg = "<span class='notice'>You are starting to [eyes.surgery_stage == BP_DEFAULT_OS ? "separate" : "extract"] eyes from [surgery_victim]'s eyelid with \the [I].</span>"
				user.visible_message(msg, self_msg)

		if(O_MOUTH)
		// Cut|Screw Face
			var/obj/item/organ/external/head/head = bodypart
			if(head.ps_status == BP_DEFAULT_OS || head.ps_status == BP_RETRACT_OS)
			//start operate face|plastic surgery
				if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
					msg = "<span class='notice'>[user] begin to [bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s screen with \the [I].</span>"
					self_msg = "<span class='notice'>You start to [bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s screen with \the [I].</span>"
				else
					msg = "<span class='notice'>[user] begin to [head.ps_status == BP_DEFAULT_OS ? "cut open [surgery_victim]'s face and neck with \the [I]" : "to alter [surgery_victim]'s appearance with \the [I]"].</span>"
					self_msg = "<span class='notice'>You start to [head.ps_status == BP_DEFAULT_OS ? "cut open [surgery_victim]'s face and neck with \the [I]" : "to alter [surgery_victim]'s appearance with \the [I]"].</span>"

				user.visible_message(msg, self_msg)

		else
		// Head, Chest, Groin, L|R Arm, L|R Leg
			if(target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && !surgery_victim.species.flags[TRAIT_NO_BLOOD] && surgery_victim.get_species() != VOX)
			//gender surgery, in this stage we need check only VOX
				msg = "<span class='notice'>[user] begin to reshape [surgery_victim]'s genitals to look more [surgery_victim.gender == FEMALE ? "masculine" : "feminine" ] with \the [I].</span>"
				self_msg = "<span class='notice'>You start to reshape [surgery_victim]'s genitals to look more [surgery_victim.gender == FEMALE ? "masculine" : "feminine" ] with \the [I].</span>"
				user.visible_message(msg, self_msg)

			if(bodypart.open == BP_RIBCAGE_OS)
				msg = "<span class='notice'>[user] begin poking around inside the [surgery_victim]'s [bodypart.name] with \the [I].</span>"
				self_msg = "<span class='notice'>You start poking around inside the [surgery_victim]'s [bodypart.name] with \the [I].</span>"
				user.visible_message(msg, self_msg)

			if(bodypart.open == BP_DEFAULT_OS || (bodypart.controller.bodypart_type == BODYPART_ROBOTIC && bodypart.open == BP_SCALPEL_OS))
			// Cut|Screw Default|Limb cut replace stump to health part
				var/datum/reagents/R = surgery_victim.reagents
				if(!R.has_reagent("metatrombine") || I.damtype != BURN || !surgery_victim.species.flags[TRAIT_NO_BLOOD])
					bodypart.status |= ORGAN_BLEEDING
				if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)

					msg = "<span class='notice'>[user] begin to [isstump(bodypart) ? "reposition wires where [surgery_victim]'s [bodypart] used to be with \the [I]" : "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [I]"].</span>"
					self_msg = "<span class='notice'>You start to [isstump(bodypart) ? "reposition wires where [surgery_victim]'s [bodypart] used to be with \the [I]" : "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [I]"].</span>"
				else
					msg = "<span class='notice'>[user] begin to [isstump(bodypart) ? "cut away flesh on [surgery_victim]'s [bodypart.name] used to be with \the [I]." : "make a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [I]"].</span>"
					self_msg = "<span class='notice'>You start to [isstump(bodypart) ? "cut away flesh on [surgery_victim]'s [bodypart.name] used to be with \the [I]." : "make a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [I]"].</span>"

				user.visible_message(msg, self_msg)


/datum/surgery_step/cut/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/I)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		msg = "<span class='notice'>[user] finish cut through [slime]'s [slime.surgery_status == SLIME_SKIN_CUTTED ? "silky innards" : "flesh"] with \the [I].</span>"
		self_msg = "<span class='notice'>You finish cut through [slime]'s [slime.surgery_status == SLIME_SKIN_CUTTED ? "silky innards" : "flesh"] with \the [I], exposing the cores.</span>"
		switch(slime.surgery_status)
			if(SLIME_SKIN_NORMAL_STATE)
			// cut flesh
				slime.surgery_status = SLIME_SKIN_CUTTED
			if(SLIME_SKIN_CUTTED)
			// cut internals flesh
				slime.surgery_status = SLIME_SKIN_PREPARED
		user.visible_message(msg, self_msg)
		return

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	switch(target_zone)
		if(O_EYES)
		// Cut|Screw Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(eyes.status & ORGAN_ROBOT)
				msg = "<span class='notice'>[user] are finish to [eyes.surgery_stage == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [eyes.name] panels with \the [I]].</span>"
				self_msg = "<span class='notice'>You are finish to [eyes.surgery_stage == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [eyes.name] panels with \the [I]].</span>"
			else
				msg = "<span class='notice'>[user] are finish to [eyes.surgery_stage == BP_DEFAULT_OS ? "separate" : "extract"] eyes from [surgery_victim]'s eyelid with \the [I].</span>"
				self_msg = "<span class='notice'>You are finish to [eyes.surgery_stage == BP_DEFAULT_OS ? "separate" : "extract"] eyes from [surgery_victim]'s eyelid with \the [I].</span>"
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
				surgery_victim.blinded += 1.5
			else
				msg = "<span class='notice'>[user] could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [I] out.</span>"
				self_msg = "<span class='notice'>You could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [I] out.</span>"
		if(O_MOUTH)
		// Cut|Screw Face
			var/obj/item/organ/external/head/head = bodypart
			if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
				msg = "<span class='notice'>[user] finish to [bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s screen with \the [I].</span>"
				self_msg = "<span class='notice'>You finish to [bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s screen with \the [I].</span>"
			else
				msg = "<span class='notice'>[user] finish to [head.ps_status == BP_DEFAULT_OS ? "cut open [surgery_victim]'s face and neck with \the [I]" : "to alter [surgery_victim]'s appearance with \the [I]"].</span>"
				self_msg = "<span class='notice'>You finish to [head.ps_status == BP_DEFAULT_OS ? "cut open [surgery_victim]'s face and neck with \the [I]" : "to alter [surgery_victim]'s appearance with \the [I]"].</span>"

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
			if(target_zone == BP_GROIN && bodypart.open >= BP_SCALPEL_OS && !surgery_victim.species.flags[TRAIT_NO_BLOOD] && surgery_victim.get_species() != VOX)
			// Gender surgery, in this stage we need check only VOX
				msg = "<span class='notice'>[user] finish to reshape [surgery_victim]'s genitals to look more [surgery_victim.gender == FEMALE ? "masculine" : "feminine" ] with \the [I].</span>"
				self_msg = "<span class='notice'>You finish to reshape [surgery_victim]'s genitals to look more [surgery_victim.gender == FEMALE ? "masculine" : "feminine" ] with \the [I].</span>"
				target.gender = target.gender == MALE ? FEMALE : MALE
				surgery_victim.regenerate_icons()
			if(bodypart.open == BP_RIBCAGE_OS)
			// Detach organ or brain
				if(!length(bodypart.bodypart_organs))
					msg = "<span class='notice'>[user] could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [I] out.</span>"
					self_msg = "<span class='notice'>You could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [I] out.</span>"
					user.visible_message(msg, self_msg)
					return FALSE
				else
					msg = "<span class='notice'>You finish to poking around inside the [surgery_victim]'s [bodypart.name] with \the [I].</span>"
					self_msg = "<span class='notice'>You finish to poking around inside the [surgery_victim]'s [bodypart.name] with \the [I].</span>"
					var/list/organs_list = list()
					for(var/atom/embed_organ in bodypart.bodypart_organs)
						organs_list[embed_organ] = embed_organ.appearance
					var/choosen_organ = show_radial_menu(user, surgery_victim, organs_list, radius = 50, require_near = TRUE, tooltips = TRUE)
					if(!choosen_organ)
						msg = "<span class='notice'>[user] could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [I] out.</span>"
						self_msg = "<span class='notice'>You could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [I] out.</span>"
						user.visible_message(msg, self_msg)
						return FALSE
					var/obj/item/organ/internal/IO = choosen_organ
					if(isbrain(IO))
						prepare_to_detach_brain(user, surgery_victim, bodypart, I)
						switch(surgery_victim.get_species())
							if(DIONA)
								msg = "<span class='notice'>You finish to separating connections roots to [surgery_victim]'s nymph with \the [I].</span>"
								self_msg = "<span class='notice'>You finish to separating connections roots to [surgery_victim]'s nymph with \the [I].</span>"
							if(IPC)
								msg = "<span class='notice'>You finish to detach wires on [surgery_victim]'s [bodypart.name] connected to positron brain unit with \the [I].</span>"
								self_msg = "<span class='notice'>You finish to detach wires on [surgery_victim]'s [bodypart.name] connected to positron brain unit with \the [I].</span>"
							else // human, skrell, tajaran, unathi, vox, etc
								msg = "<span class='notice'>You finish to separates [surgery_victim]'s brain from \his spine with \the [I].</span>"
								self_msg = "<span class='notice'>You finish to separates [surgery_victim]'s brain from \his spine with \the [I].</span>"

					IO.status |= ORGAN_CUT_AWAY
					IO.remove(surgery_victim)
					IO.loc = get_turf(surgery_victim)
					bodypart.bodypart_organs  -= IO
					playsound(surgery_victim, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
			if(bodypart.open == BP_DEFAULT_OS || (bodypart.controller.bodypart_type == BODYPART_ROBOTIC && bodypart.open == BP_SCALPEL_OS))
			// Cut|Screw Default
				if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
					msg = "<span class='notice'>[user] finish to [isstump(bodypart) ? "reposition wires where [surgery_victim]'s [bodypart] used to be with \the [I]" : "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [I]"].</span>"
					self_msg = "<span class='notice'>You finish to [isstump(bodypart) ? "reposition wires where [surgery_victim]'s [bodypart] used to be with \the [I]" : "[bodypart.open == BP_DEFAULT_OS ? "un" : null]screw [surgery_victim]'s [bodypart.name]'s maintenance hatch with \the [I]"].</span>"
				else
					msg = "<span class='notice'>[user] finish to [isstump(bodypart) ? "cut away flesh on [surgery_victim]'s [bodypart.name] used to be with \the [I]." : "make a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [I]"].</span>"
					self_msg = "<span class='notice'>You finish to [isstump(bodypart) ? "cut away flesh on [surgery_victim]'s [bodypart.name] used to be with \the [I]." : "make a [bodypart.status & ORGAN_BLEEDING ? null : "bloodless "]incision on [surgery_victim]'s [bodypart.name] with \the [I]"].</span>"

				cp_msg = "You feel a horrible pain as if from a sharp knife in your [bodypart.name]!"

				bodypart.open = (bodypart.open == BP_SCALPEL_OS && bodypart.controller.bodypart_type == BODYPART_ROBOTIC) ? BP_DEFAULT_OS : BP_SCALPEL_OS

				if(bodypart.controller.bodypart_type != BODYPART_ROBOTIC)
					bodypart.take_damage(1, 1, DAM_SHARP|DAM_EDGE, I)

	user.visible_message(msg, self_msg)
	surgery_victim.custom_pain(cp_msg, 1)
