//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (isslime(target))
			return 0
		if (target_zone == O_EYES)	//there are specific steps for eye surgery
			return 0
		if (!ishuman(target))
			return 0
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP == null)
			return 0
		if (BP.status & ORGAN_DESTROYED)
			return 0
		if (target_zone == BP_HEAD && target.species && (target.species.flags[IS_SYNTHETIC]))
			return 1
		if (BP.status & ORGAN_ROBOT)
			return 0
		return 1

/datum/surgery_step/generic/cut_with_laser
	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 95, \
	/obj/item/weapon/scalpel/laser2 = 85, \
	/obj/item/weapon/scalpel/laser1 = 75, \
	/obj/item/weapon/melee/energy/sword = 5
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 0 && target_zone != O_MOUTH

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts the bloodless incision on [target]'s [BP.name] with \the [tool].", \
		"You start the bloodless incision on [target]'s [BP.name] with \the [tool].")
		target.custom_pain("You feel a horrible, searing pain in your [BP.name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has made a bloodless incision on [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You have made a bloodless incision on [target]'s [BP.name] with \the [tool].</span>",)
		//Could be cleaner ...
		BP.open = 1
		BP.status |= ORGAN_BLEEDING
		BP.createwound(CUT, 1)
		BP.clamp()
		spread_germs_to_organ(BP, user)
		if (target_zone == BP_HEAD)
			target.brain_op_stage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips as the blade sputters, searing a long gash in [target]'s [BP.name] with \the [tool]!", \
		"\red Your hand slips as the blade sputters, searing a long gash in [target]'s [BP.name] with \the [tool]!")
		BP.createwound(CUT, 7.5)
		BP.createwound(BURN, 12.5)

/datum/surgery_step/generic/incision_manager
	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 100
	)

	min_duration = 80
	max_duration = 120

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 0 && target_zone != O_MOUTH

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts to construct a prepared incision on and within [target]'s [BP.name] with \the [tool].", \
		"You start to construct a prepared incision on and within [target]'s [BP.name] with \the [tool].")
		target.custom_pain("You feel a horrible, searing pain in your [BP.name] as it is pushed apart!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has constructed a prepared incision on and within [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You have constructed a prepared incision on and within [target]'s [BP.name] with \the [tool].</span>",)
		BP.open = 1
		BP.status |= ORGAN_BLEEDING
		BP.createwound(CUT, 1)
		BP.clamp()
		BP.open = 2
		if (target_zone == BP_HEAD)
			target.brain_op_stage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [BP.name] with \the [tool]!", \
		"\red Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [BP.name] with \the [tool]!")
		BP.createwound(CUT, 20)
		BP.createwound(BURN, 15)

/datum/surgery_step/generic/cut_open
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 0 && target_zone != O_MOUTH

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts the incision on [target]'s [BP.name] with \the [tool].", \
		"You start the incision on [target]'s [BP.name] with \the [tool].")
		target.custom_pain("You feel a horrible pain as if from a sharp knife in your [BP.name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You have made an incision on [target]'s [BP.name] with \the [tool].</span>",)
		BP.open = 1
		BP.status |= ORGAN_BLEEDING
		BP.createwound(CUT, 1)
		if (target_zone == BP_HEAD)
			target.brain_op_stage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!", \
		"\red Your hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!")
		BP.createwound(CUT, 10)

/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,             \
	/obj/item/weapon/cable_coil = 75,            \
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open && (BP.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts clamping bleeders in [target]'s [BP.name] with \the [tool].", \
		"You start clamping bleeders in [target]'s [BP.name] with \the [tool].")
		target.custom_pain("The pain in your [BP.name] is maddening!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [BP.name] with \the [tool].</span>",	\
		"<span class='notice'>You clamp bleeders in [target]'s [BP.name] with \the [tool].</span>")
		BP.clamp()

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [BP.name] with \the [tool]!",	\
		"\red Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [BP.name] with \the [tool]!",)
		BP.createwound(CUT, 10)

/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 30
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 1 && !(BP.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		var/msg = "[user] starts to pry open the incision on [target]'s [BP.name] with \the [tool]."
		var/self_msg = "You start to pry open the incision on [target]'s [BP.name] with \the [tool]."
		if (target_zone == BP_HEAD)
			msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
			self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		if (target_zone == BP_GROIN)
			msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
			self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("It feels like the skin on your [BP.name] is on fire!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		var/msg = "<span class='notice'>[user] keeps the incision open on [target]'s [BP.name] with \the [tool].</span>"
		var/self_msg = "<span class='notice'>You keep the incision open on [target]'s [BP.name] with \the [tool].</span>"
		if (target_zone == BP_CHEST)
			msg = "<span class='notice'>[user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
			self_msg = "<span class='notice'>You keep the ribcage open on [target]'s torso with \the [tool].</span>"
		if (target_zone == BP_GROIN)
			msg = "<span class='notice'>[user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
			self_msg = "<span class='notice'>You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
		user.visible_message(msg, self_msg)
		BP.open = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		var/msg = "\red [user]'s hand slips, tearing the edges of the incision on [target]'s [BP.name] with \the [tool]!"
		var/self_msg = "\red Your hand slips, tearing the edges of the incision on [target]'s [BP.name] with \the [tool]!"
		if (target_zone == BP_CHEST)
			msg = "\red [user]'s hand slips, damaging several organs in [target]'s torso with \the [tool]!"
			self_msg = "\red Your hand slips, damaging several organs in [target]'s torso with \the [tool]!"
		if (target_zone == BP_GROIN)
			msg = "\red [user]'s hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]"
			self_msg = "\red Your hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!"
		user.visible_message(msg, self_msg)
		target.apply_damage(12, BRUTE, BP, sharp = 1)

/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open && target_zone != O_MOUTH

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s [BP.name] with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s [BP.name] with \the [tool].")
		target.custom_pain("Your [BP.name] is being burned!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You cauterize the incision on [target]'s [BP.name] with \the [tool].</span>")
		BP.open = 0
		BP.status &= ~ORGAN_BLEEDING

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!", \
		"\red Your hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!")
		target.apply_damage(3, BURN, BP)

/datum/surgery_step/generic/cut_limb
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 110
	max_duration = 160

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone == O_EYES) // there are specific steps for eye surgery
			return 0
		if (!ishuman(target))
			return 0
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP == null)
			return 0
		if (BP.status & ORGAN_DESTROYED)
			return 0
		return target_zone != BP_CHEST && target_zone != BP_GROIN && target_zone != BP_HEAD

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] is beginning to cut off [target]'s [BP.name] with \the [tool]." , \
		"You are beginning to cut off [target]'s [BP.name] with \the [tool].")
		target.custom_pain("Your [BP.name] is being ripped apart!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] cuts off [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You cut off [target]'s [BP.name] with \the [tool].</span>")
		BP.droplimb(1, 0)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("\red [user]'s hand slips, sawwing through the bone in [target]'s [BP.name] with \the [tool]!", \
		"\red Your hand slips, sawwing through the bone in [target]'s [BP.name] with \the [tool]!")
		BP.createwound(CUT, 30)
		BP.fracture()
