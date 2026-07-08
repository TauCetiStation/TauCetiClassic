// Condition content
#define EYES_SURGERY                   (!(eyes.status & ORGAN_ROBOT) && eyes.surgery_stage == BP_SCALPEL_OS)
#define MOUTH_SURGERY                  (!(bodypart.controller.bodypart_type == BODYPART_ROBOTIC) && head.ps_status >= BP_SCALPEL_OS)
#define FATTAS_SURGERY                 (!(bodypart.controller.bodypart_type == BODYPART_ROBOTIC) && HAS_TRAIT(surgery_victim, TRAIT_FAT) && bodypart.open == BP_INTERNALS_OS)
#define RETRACT_PRY                    (bodypart.open > BP_DEFAULT_OS)

// Output Sortcut Defines
#define MOUTH_ACTION                   "[head.ps_status == BP_INTERNALS_OS ? "adjust": "pull"] the skin on [surgery_victim]'s face back in place with \the [tool]"
#define EYES_ACTION                    "lifting corneas from [surgery_victim]'s eyes with \the [tool]"
#define FATTAS_ACTION                  "extract [surgery_victim]'s loose fat with \the [tool]"

// Pry or retract
#define RETREAC_ACTION                 "to pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] the [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "incision" : "ribcage"] on [surgery_victim]'s [bodypart.name] with \the [tool]"
#define PRY_ACTION                     "pry [(bodypart.open == BP_RIBCAGE_OS || bodypart.open == BP_RETRACT_OS) ? "close" : "open"] [(bodypart.open == BP_SCALPEL_OS || bodypart.open == BP_RETRACT_OS) ? "security" : "maintance"] panel on [surgery_victim]' with \the [tool]"
#define SIMPLE_PRY_RETRACT_ACTION      bodypart.controller.bodypart_type == BODYPART_ROBOTIC ? PRY_ACTION : RETREAC_ACTION

// Action
/datum/surgery_step/retract
	allowed_qualities = list(
		QUALITY_RETRACT,
		QUALITY_PRYING
		)
	allowed_species = list("exclude", DIONA)
	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/retract/prepare_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	return TRUE

/datum/surgery_step/retract/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	//human, unathi, tajaran, skrell, ipc and etc
	switch(target_zone)
		if(O_EYES)
		// Retract Eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			if(EYES_SURGERY)
				msg = "<span class='notice'>[user] being to [EYES_ACTION].</span>"
				self_msg = "<span class='notice'>You start to [EYES_ACTION].</span>"
				user.visible_message(msg, self_msg)
				return TRUE
		if(O_MOUTH)
		// Retract Face
			var/obj/item/organ/external/head/head = bodypart
			if(MOUTH_SURGERY)
				msg = "<span class='notice'>[user] starts [MOUTH_ACTION].</span>"
				self_msg = "<span class='notice'>You start [MOUTH_ACTION].</span>"
				user.visible_message(msg, self_msg)
		else // Head, Chest, Groin, L|R Arm, L|R Leg
			if(FATTAS_SURGERY)
				msg = "<span class='notice'>[user] begins to [FATTAS_ACTION].</span>"
				self_msg = "<span class='notice'>You begins to [FATTAS_ACTION].</span>"
				user.visible_message(msg, self_msg)
				return TRUE
			//ribcage & retract skin & remove fat
			if(RETRACT_PRY)
				msg = "<span class='notice'>[user] being to [SIMPLE_PRY_RETRACT_ACTION].</span>"
				self_msg = "<span class='notice'>You start to [SIMPLE_PRY_RETRACT_ACTION].</span>"
				user.visible_message(msg, self_msg)
				return TRUE

/datum/surgery_step/retract/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	//human, unathi, tajaran, skrell, ipc and etc)

	switch(target_zone)
		if(O_EYES)
		//eyes
			var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
			msg = "<span class='notice'>[user] finish to [EYES_ACTION].</span>"
			self_msg = "<span class='notice'>You finish to [EYES_ACTION].</span>"
			eyes.surgery_stage = BP_RETRACT_OS
		if(O_MOUTH)
		//face & plastic surgery
			var/obj/item/organ/external/head/head = surgery_victim.get_bodypart(target_zone)
			msg = "<span class='notice'>[user] starts [MOUTH_ACTION].</span>"
			self_msg = "<span class='notice'>You start [MOUTH_ACTION].</span>"
			user.visible_message(msg, self_msg)
			head.ps_status = bodypart.open == BP_SCALPEL_OS ? BP_RETRACT_OS : BP_SCALPEL_OS
		else
			if(HAS_TRAIT(surgery_victim, TRAIT_FAT))
			//remove_fat
				msg = "<span class='notice'>[user] finish [FATTAS_ACTION].</span>"
				self_msg = "<span class='notice'>You finish [FATTAS_ACTION].</span>"
				user.visible_message(msg, self_msg)
				liposacsy(user, surgery_victim, tool)
			else
				msg = "<span class='notice'>[user] finish to [SIMPLE_PRY_RETRACT_ACTION].</span>"
				self_msg = "<span class='notice'>You finish to [SIMPLE_PRY_RETRACT_ACTION].</span>"
				switch(bodypart.open)
					if(BP_SCALPEL_OS, BP_RETRACT_OS)
					//retract skin
						user.visible_message(msg, self_msg)
						bodypart.open = bodypart.open == BP_RETRACT_OS ? BP_SCALPEL_OS : BP_RETRACT_OS
					if(BP_INTERNALS_OS, BP_RIBCAGE_OS)
					//open|close ribcage
						user.visible_message(msg, self_msg)
						bodypart.open = bodypart.open == BP_RIBCAGE_OS ? BP_INTERNALS_OS : BP_RIBCAGE_OS


/datum/surgery_step/retract/proc/liposacsy(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/tool)
	surgery_victim.nutrition = 450
	surgery_victim.overeatduration = 0
	REMOVE_TRAIT(surgery_victim, TRAIT_FAT, INNATE_TRAIT)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/fattymeat = new(surgery_victim.loc)
	fattymeat.name = "fatty meat"
	fattymeat.desc = "Extremely fatty tissue taken from a patient."
	fattymeat.reagents.add_reagent ("nutriment", (max(75, (surgery_victim.nutrition + surgery_victim.overeatduration) - 450) / 15))
	playsound(surgery_victim, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
