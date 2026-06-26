/datum/surgery_step/retract
	allowed_qualities = list(
		QUALITY_RETRACT,
		QUALITY_WRENCHING
		)
	allowed_species = list("exclude", DIONA)
	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/retract/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!ishuman(surgery_victim))
		return FALSE
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)

	//limb	//limb/ipc_prepare
	if(BP.is_stump())
		return TRUE

/////////////////////////////////////
///       IPC SURGERY CUT         ///
/////////////////////////////////////
	if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		can_infect = FALSE
		switch(target_zone)
			if(BP_CHEST)
				switch(BP.open)
					if(BP_SECURITY_PANEL_OPEN)
					//wrench_sec
						return TRUE
					if(BP_MAINTANCE_PANEL_OPEN)
					//wrenchshut_sec
						return TRUE
/////////////////////////////////////
///     ORGANIC SURGERY CUT       ///
/////////////////////////////////////
	else if(!surgery_victim.species.flags[TRAIT_NO_BLOOD]) // human, unathi, tajaran, skrell and etc
		if(!BP.status & ORGAN_BLEEDING)
			switch(target_zone)
				if(O_EYES)
				//eyes
					var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
					if(eyes.surgery_stage == BP_SCALPEL_OPEN_STATE)
						return TRUE
				if(O_MOUTH)
				//face & plastic surgery
					var/obj/item/organ/external/head/head = BP
					if(head.ps_status >= BP_SCALPEL_OPEN_STATE)
						user.visible_message("[user] starts pulling the skin on [surgery_victim]'s face back in place with \the [tool].", \
						"You start pulling the skin on [surgery_victim]'s face back in place with \the [tool].")
						return TRUE
				else
				//ribcage & retract skin & remove fat
					if(BP.open >= BP_SCALPEL_OPEN_STATE)
						return TRUE

/datum/surgery_step/retract/prepare_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	return TRUE

/datum/surgery_step/retract/begin_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	//IPC SURGERY
	//limb/ipc_prepare
	if(BP.is_stump())
		user.visible_message("[user] starts adjusting the area around [surgery_victim]'s [parse_zone(target_zone)] with \the [tool].",
		"You start adjusting the area around [surgery_victim]'s [parse_zone(target_zone)] with \the [tool].")
/////////////////////////////////////
///       IPC SURGERY CUT         ///
/////////////////////////////////////
	if(surgery_victim.species.flags[IS_SYNTHETIC]) // IPC only
		switch(target_zone)
			if(BP_CHEST)
				switch(BP.open)
					if(BP_SECURITY_PANEL_OPEN)
					//wrench_sec
						msg = "[user] begins to loosen bolts on [surgery_victim]'s security panel with \the [tool]."
						self_msg = "You begin to loosen bolts on [surgery_victim]'s security panel with \the [tool]."
						if(!surgery_victim.is_bruised_organ(O_KIDNEYS))
							to_chat(surgery_victim, "%MAIN SECURITY PANEL% UNATHORISED ACCESS ATTEMPT DETECTED!")
					if(BP_MAINTANCE_PANEL_OPEN)
					//wrenchshut_sec
						msg = "[user] starts tighetning bolts on [surgery_victim]'s security panel with \the [tool]."
						self_msg = "You start tighetning bolts on [surgery_victim]'s security panel with \the [tool]."
/////////////////////////////////////
///     ORGANIC SURGERY CUT       ///
/////////////////////////////////////
	else if(!surgery_victim.species.flags[TRAIT_NO_BLOOD]) // human, unathi, tajaran, skrell and etc
		switch(target_zone)
			if(O_EYES)
			//eyes
				msg = "[user] starts lifting corneas from [surgery_victim]'s eyes with \the [tool]."
				self_msg = "You start lifting corneas from [surgery_victim]'s eyes with \the [tool]."
			if(O_MOUTH)
			//face & plastic surgery
				var/obj/item/organ/external/head/head = BP
				if(head.ps_status == BP_SAW_INTERNALS_OPEN_STATE)
					msg = "<span class='notice'>[user] pulls the skin on [surgery_victim]'s face back in place with \the [tool].</span>"
					self_msg = "<span class='notice'>You pull the skin on [surgery_victim]'s face back in place with \the [tool].</span>"
					surgery_victim.op_stage.face = 3
				else if(head.ps_status == BP_SCALPEL_OPEN_STATE)
				msg = "[user] starts adjusting the skin on [surgery_victim]'s face with \the [tool]."
				self_msg = "You start adjusting the skin on [surgery_victim]'s face with \the [tool]."

			else
				//open ribcage
				msg = "[user] starts to force open the ribcage in [surgery_victim]'s torso with \the [tool]."
				self_msg = "You start to force open the ribcage in [surgery_victim]'s torso with \the [tool]."

				cp_msg = "[HAS_TRAIT(surgery_victim, TRAIT_NO_PAIN) ? "You notice movement inside your chest!" : "Something hurts horribly in your chest!"]"

				//close ribcage
				msg = "[user] starts bending [surgery_victim]'s ribcage back into place with \the [tool]."
				self_msg = "You start bending [surgery_victim]'s ribcage back into place with \the [tool]."

				cp_msg = "Something hurts horribly in your chest!"



		//retract skin
		msg = "[user] starts to pry open the incision on [surgery_victim]'s [BP.name] with \the [tool]."
		self_msg = "You start to pry open the incision on [surgery_victim]'s [BP.name] with \the [tool]."
		if(target_zone == BP_CHEST)
			msg = "[user] starts to separate the ribcage and rearrange the organs in [surgery_victim]'s torso with \the [tool]."
			self_msg = "You start to separate the ribcage and rearrange the organs in [surgery_victim]'s torso with \the [tool]."
		if(target_zone == BP_GROIN)
			msg = "[user] starts to pry open the incision and rearrange the organs in [surgery_victim]'s lower abdomen with \the [tool]."
			self_msg = "You start to pry open the incision and rearrange the organs in [surgery_victim]'s lower abdomen with \the [tool]."

		cp_msg = "It feels like the skin on your [BP.name] is on fire!"

		//limb
		msg = "[user] is beginning to reposition flesh and nerve endings where where [surgery_victim]'s [parse_zone(target_zone)] used to be with [tool]."
		self_msg = "You start repositioning flesh and nerve endings where [surgery_victim]'s [parse_zone(target_zone)] used to be with [tool]."

		//remove_fat
		msg = "[user] begins to extract [surgery_victim]'s loose fat with \the [tool]."
		self_msg = "You begin to extract [surgery_victim]'s loose fat with \the [tool]."
		if(surgery_victim.overeatduration > 0)
			cp_msg = "Something hurts horribly in your chest!"

	user.visible_message(msg, self_msg)
	surgery_victim.custom_pain(cp_msg, 1)
	..()

/datum/surgery_step/retract/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)

	//IPC SURGERY
	//limb/ipc_prepare
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [surgery_victim]'s [parse_zone(target_zone)] with \the [tool].</span>",
	"<span class='notice'>You have finished adjusting the area around [surgery_victim]'s [parse_zone(target_zone)] with \the [tool].</span>")
	surgery_victim.op_stage.bodyparts[target_zone] = ORGAN_ATTACHABLE

	//wrench_shut
	user.visible_message("<span class='notice'> [user] has loosen bolts on [surgery_victim]'s security panel with \the [tool].</span>",
	"<span class='notice'> You have loosen bolts on [surgery_victim]'s security panel with \the [tool].</span>")
	surgery_victim.op_stage.ribcage = 1

	//wrenchshut_sec
	user.visible_message("<span class='notice'> [user] has loosen bolts on [surgery_victim]'s security panel with \the [tool].</span>",
	"<span class='notice'> You have loosen bolts on [surgery_victim]'s security panel with \the [tool].</span>")

	surgery_victim.op_stage.ribcage = 0

	BP.open = 1

	//wrench_sec
	user.visible_message("<span class='notice'> [user] has loosen bolts on [surgery_victim]'s security panel with \the [tool].</span>",
	"<span class='notice'> You have loosen bolts on [surgery_victim]'s security panel with \the [tool].</span>")
	surgery_victim.op_stage.ribcage = 1

	//ribcage
	msg = "<span class='notice'>[user] forces open [surgery_victim]'s ribcage with \the [tool].</span>"
	self_msg = "<span class='notice'>You force open [surgery_victim]'s ribcage with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	surgery_victim.op_stage.ribcage = 2
	BP.open = 3

	msg = "<span class='notice'>[user] bends [surgery_victim]'s ribcage back into place with \the [tool].</span>"
	self_msg = "<span class='notice'>You bend [surgery_victim]'s ribcage back into place with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	BP.open = BP_RETRACTOR_OPEN_STATE

	//eyes
	var/obj/item/organ/internal/eyes/eyes = surgery_victim:organs_by_name[O_EYES]
	user.visible_message("<span class='notice'>[user] has lifted the corneas from [surgery_victim]'s eyes from with \the [tool].</span>" , \
	"<span class='notice'>You has lifted the corneas from [surgery_victim]'s eyes from with \the [tool].</span>" )
	eyes.

	//face & plastic surgery
	user.visible_message("<span class='notice'>[user] pulls the skin on [surgery_victim]'s face back in place with \the [tool].</span>",	\
	"<span class='notice'>You pull the skin on [surgery_victim]'s face back in place with \the [tool].</span>")
	surgery_victim.op_stage.face = 3

	user.visible_message("<span class='notice'>[user] pulls the skin on [surgery_victim]'s face with \the [tool].</span>",	\
	"<span class='notice'>You pull the skin on [surgery_victim]'s face with \the [tool].</span>")
	surgery_victim.op_stage.plasticsur = 1

	//retract skin
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	var/msg = "<span class='notice'>[user] keeps the incision open on [surgery_victim]'s [BP.name] with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You keep the incision open on [surgery_victim]'s [BP.name] with \the [tool].</span>"
	if (target_zone == BP_CHEST)
		msg = "<span class='notice'>[user] keeps the ribcage open on [surgery_victim]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'>You keep the ribcage open on [surgery_victim]'s torso with \the [tool].</span>"
	if (target_zone == BP_GROIN)
		msg = "<span class='notice'>[user] keeps the incision open on [surgery_victim]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'>You keep the incision open on [surgery_victim]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	BP.open = 2

	//limb
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [surgery_victim]'s [parse_zone(target_zone)] used to be with [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and nerve endings where [surgery_victim]'s [parse_zone(target_zone)] used to be with [tool].</span>")
	surgery_victim.op_stage.bodyparts[target_zone] = 3

	//remove_fat
	surgery_victim.op_stage.lipoplasty = 0
	if (surgery_victim.overeatduration > 0)
		user.visible_message("<span class='notice'>[user] extracts [surgery_victim]'s fat with \the [tool].</span>",		\
		"<span class='notice'>You have removed [surgery_victim]'s fat loose with \the [tool].</span>")
		var/removednutriment = max(75, (surgery_victim.nutrition + surgery_victim.overeatduration) - 450)
		surgery_victim.nutrition = 450
		surgery_victim.overeatduration = 0
		var/obj/item/weapon/reagent_containers/food/snacks/meat/P = new
		P.name = "fatty meat"
		P.desc = "Extremely fatty tissue taken from a patient."
		P.reagents.add_reagent ("nutriment", (removednutriment / 15))
		var/amount = 0
		if (surgery_victim.reagents.total_volume > 0)
			amount = surgery_victim.reagents.total_volume
			surgery_victim.reagents.remove_reagent("nutriment",amount)
		var/obj/item/meatslab = P
		meatslab.loc = get_turf(surgery_victim)
		playsound(surgery_victim, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
	else
		user.visible_message("<span class='notice'>Unfortunately, there is nothing to extract of [surgery_victim]'s with \the [tool].</span>",		\
		"<span class='notice'>Unfortunately, there is nothing to extract of [surgery_victim] with \the [tool].</span>")


/datum/surgery_step/retract/fail_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	//IPC SURGERY
	//limb/ipc_prepare
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, denting [surgery_victim]'s [BP.name]!</span>",
		"<span class='warning'>Your hand slips, searing [surgery_victim]'s [BP.name]!</span>")
		surgery_victim.apply_damage(10, BRUTE, BP)

	//wrench_shut
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [surgery_victim]'s security panel with \the [tool]!</span>" ,
	"<span class='warning'>Your hand slips, scratching [surgery_victim]'s security panel with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

	//wrenchshut_sec
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [surgery_victim]'s security panel with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [surgery_victim]'s security panel with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
	//wrench_sec
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [surgery_victim]'s security panel with \the [tool]!</span>" ,
	"<span class='warning'>Your hand slips, scratching [surgery_victim]'s security panel with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

	//ribcage
	var/msg = "<span class='warning'>[user]'s hand slips, breaking [surgery_victim]'s ribcage!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, breaking [surgery_victim]'s ribcage!</span>"
	user.visible_message(msg, self_msg)
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	BP.fracture()
	BP.take_damage(20, 0, used_weapon = tool)

	var/msg = "<span class='warning'>[user]'s hand slips, bending [surgery_victim]'s ribs the wrong way!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, bending [surgery_victim]'s ribs the wrong way!</span>"
	user.visible_message(msg, self_msg)
	var/obj/item/organ/external/chest/BP = surgery_victim.get_bodypart(BP_CHEST)
	BP.fracture()
	BP.take_damage(20, 0, used_weapon = tool)
	if (prob(40))
		user.visible_message("<span class='warning'>A rib pierces the lung!</span>")
		surgery_victim.rupture_lung()

	//eyes
	var/obj/item/organ/internal/eyes/IO = surgery_victim.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [surgery_victim]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging [surgery_victim]'s eyes with \the [tool]!</span>")
	BP.take_damage(10, 0, used_weapon = tool)
	IO.take_damage(5, 0)

	//face && plastic surgery
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [surgery_victim]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [surgery_victim]'s face with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [surgery_victim]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [surgery_victim]'s face with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)


	//retract skin
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of the incision on [surgery_victim]'s [BP.name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, tearing the edges of the incision on [surgery_victim]'s [BP.name] with \the [tool]!</span>"
	if (target_zone == BP_CHEST)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [surgery_victim]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [surgery_victim]'s torso with \the [tool]!</span>"
	if (target_zone == BP_GROIN)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [surgery_victim]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [surgery_victim]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	BP.take_damage(12, 0, DAM_SHARP|DAM_EDGE, tool)

	//limb
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing flesh on [surgery_victim]'s [BP.name]!</span>", \
		"<span class='warning'>Your hand slips, tearing flesh on [surgery_victim]'s [BP.name]!</span>")
		surgery_victim.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)

	//remove_fat
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting [surgery_victim]'s belly with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cutting [surgery_victim]'s belly with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = surgery_victim.get_bodypart(target_zone)
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)
