/datum/surgery_step/retract
	name = "Retract"
	allowed_qualities = list(
		QUALITY_SURGERY_RETRACT,
		QUALITY_PRYING
		)
	allowed_species = list("exclude", DIONA)
	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/retract/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	if(!..())
		return FALSE

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	//human, unathi, tajaran, skrell, ipc and etc
	switch(target_zone)
		if(O_EYES)
		// Retract Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(eyes?.surgery_stage <= BP_SCALPEL_OS)
				return TRUE
		if(O_MOUTH)
		// Retract Face
			var/obj/item/organ/external/head/head = bodypart
			if(head.ps_status == BP_DEFAULT_OS || head.ps_status == BP_RETRACT_OS)
				return TRUE
		else // Head, Chest, Groin, L|R Arm, L|R Leg
			if(!(bodypart.controller.bodypart_type == BODYPART_ROBOTIC) && HAS_TRAIT(surgery_victim, TRAIT_FAT) && bodypart.open == BP_INTERNALS_OS)
				return TRUE
			//ribcage & retract skin & remove fat
			if(bodypart.open > BP_DEFAULT_OS)
				return TRUE
	return FALSE

/datum/surgery_step/retract/begin_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	. = ..()

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	//human, unathi, tajaran, skrell, ipc and etc
	switch(target_zone)
		if(O_EYES)
		// Retract Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(eyes?.surgery_stage <= BP_SCALPEL_OS)
				msg = "<span class='notice'>[user] begin to lifting corneas from [surgery_victim]'s eyes with \the [I].</span>"
				self_msg = "<span class='notice'>You start to lifting corneas from [surgery_victim]'s eyes with \the [I].</span>"
				user.visible_message(msg, self_msg)
		if(O_MOUTH)
		// Retract Face
			var/obj/item/organ/external/head/head = bodypart
			if(head.ps_status == BP_DEFAULT_OS || head.ps_status == BP_RETRACT_OS)
				msg = "<span class='notice'>[user] begin [head.ps_status == BP_INTERNALS_OS ? "adjust": "pull"] the skin on [surgery_victim]'s face back in place with \the [I].</span>"
				self_msg = "<span class='notice'>You start [head.ps_status == BP_INTERNALS_OS ? "adjust": "pull"] the skin on [surgery_victim]'s face back in place with \the [I].</span>"
				user.visible_message(msg, self_msg)
		else // Head, Chest, Groin, L|R Arm, L|R Leg
			if(!(bodypart.controller.bodypart_type == BODYPART_ROBOTIC) && HAS_TRAIT(surgery_victim, TRAIT_FAT) && bodypart.open == BP_INTERNALS_OS)
				msg = "<span class='notice'>[user] begin to extract [surgery_victim]'s loose fat with \the [I].</span>"
				self_msg = "<span class='notice'>You start to extract [surgery_victim]'s loose fat with \the [I].</span>"
				user.visible_message(msg, self_msg)
			//ribcage & retract skin & remove fat
			if(bodypart.open > BP_DEFAULT_OS)
				if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
					msg = "<span class='notice'>[user] begin to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] the [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "incision" : "ribcage"] on [surgery_victim]'s [bodypart.name] with \the [I].</span>"
					self_msg = "<span class='notice'>You start to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] the [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "incision" : "ribcage"] on [surgery_victim]'s [bodypart.name] with \the [I].</span>"
				else
					msg = "<span class='notice'>[user] begin to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "security" : "maintance"] panel on [surgery_victim]' with \the [I].</span>"
					self_msg = "<span class='notice'>You start to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "security" : "maintance"] panel on [surgery_victim]' with \the [I].</span>"
				user.visible_message(msg, self_msg)


/datum/surgery_step/retract/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	//human, unathi, tajaran, skrell, ipc and etc)

	switch(target_zone)
		if(O_EYES)
		//eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			msg = "<span class='notice'>[user] finish to lifting corneas from [surgery_victim]'s eyes with \the [I].</span>"
			self_msg = "<span class='notice'>You finish to lifting corneas from [surgery_victim]'s eyes with \the [I].</span>"
			eyes.surgery_stage = BP_RETRACT_OS
		if(O_MOUTH)
		//face & plastic surgery
			var/obj/item/organ/external/head/head = surgery_victim.get_bodypart(target_zone)
			msg = "<span class='notice'>[user] begin [head.ps_status == BP_INTERNALS_OS ? "adjust": "pull"] the skin on [surgery_victim]'s face back in place with \the [I].</span>"
			self_msg = "<span class='notice'>You start [head.ps_status == BP_INTERNALS_OS ? "adjust": "pull"] the skin on [surgery_victim]'s face back in place with \the [I].</span>"
			user.visible_message(msg, self_msg)
			head.ps_status = bodypart.open == BP_SCALPEL_OS ? BP_RETRACT_OS : BP_SCALPEL_OS
		else
			if(HAS_TRAIT(surgery_victim, TRAIT_FAT))
			//remove_fat
				msg = "<span class='notice'>[user] finish extract [surgery_victim]'s loose fat with \the [I].</span>"
				self_msg = "<span class='notice'>You finish extract [surgery_victim]'s loose fat with \the [I].</span>"
				user.visible_message(msg, self_msg)
				liposacsy(user, surgery_victim, I)
			else
				if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
					msg = "<span class='notice'>[user] finish to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] the [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "incision" : "ribcage"] on [surgery_victim]'s [bodypart.name] with \the [I].</span>"
					self_msg = "<span class='notice'>You finish to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] the [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "incision" : "ribcage"] on [surgery_victim]'s [bodypart.name] with \the [I].</span>"
				else
					msg = "<span class='notice'>[user] finish to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "security" : "maintance"] panel on [surgery_victim]' with \the [I].</span>"
					self_msg = "<span class='notice'>You finish to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "security" : "maintance"] panel on [surgery_victim]' with \the [I].</span>"
				switch(bodypart.open)
					if(BP_SCALPEL_OS, BP_RETRACT_OS)
					//retract skin
						user.visible_message(msg, self_msg)
						bodypart.open = bodypart.open == BP_RETRACT_OS ? BP_SCALPEL_OS : BP_RETRACT_OS
					if(BP_INTERNALS_OS, BP_RIBCAGE_OS)
					//open|close ribcage
						user.visible_message(msg, self_msg)
						bodypart.open = bodypart.open == BP_RIBCAGE_OS ? BP_INTERNALS_OS : BP_RIBCAGE_OS


/datum/surgery_step/retract/proc/liposacsy(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/I)
	surgery_victim.nutrition = 450
	surgery_victim.overeatduration = 0
	REMOVE_TRAIT(surgery_victim, TRAIT_FAT, INNATE_TRAIT)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/fattymeat = new(surgery_victim.loc)
	fattymeat.name = "fatty meat"
	fattymeat.desc = "Extremely fatty tissue taken from a patient."
	fattymeat.reagents.add_reagent ("nutriment", (max(75, (surgery_victim.nutrition + surgery_victim.overeatduration) - 450) / 15))
	playsound(surgery_victim, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
