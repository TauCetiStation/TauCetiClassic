//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic
	can_infect = 1

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (isslime(target))
		return 0
	if (target_zone == BP_EYES)	//there are specific steps for eye surgery
		return 0
	if (!hasbodyparts(target))
		return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP == null)
		return 0
	if (BP.is_stump())
		return 0
	if (BP.status & ORGAN_ROBOT)
		return 0
	return 1

/datum/surgery_step/generic/cut_with_laser
	allowed_tools = list(
		 /obj/item/weapon/scalpel/laser3 = 95
		,/obj/item/weapon/scalpel/laser2 = 85
		,/obj/item/weapon/scalpel/laser1 = 75
		,/obj/item/weapon/melee/energy/sword = 5
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_with_laser/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != BP_MOUTH

/datum/surgery_step/generic/cut_with_laser/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts the bloodless incision on [target]'s [BP.name] with \the [tool].",
		                     "You start the bloodless incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [BP.name]!",50, BP = BP)
	..()

/datum/surgery_step/generic/cut_with_laser/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has made a bloodless incision on [target]'s [BP.name] with \the [tool].",
		                   "\blue You have made a bloodless incision on [target]'s [BP.name] with \the [tool].",)
	//Could be cleaner ...
	BP.open = 1

	BP.createwound(CUT, 1)
	BP.clamp()
	spread_germs_to_bodypart(BP, user)

/datum/surgery_step/generic/cut_with_laser/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips as the blade sputters, searing a long gash in [target]'s [BP.name] with \the [tool]!",
		                     "\red Your hand slips as the blade sputters, searing a long gash in [target]'s [BP.name] with \the [tool]!")
	BP.take_damage(12.5, 7.5, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

/datum/surgery_step/generic/incision_manager
	allowed_tools = list(
		/obj/item/weapon/scalpel/manager = 100
	)

	min_duration = 80
	max_duration = 120

/datum/surgery_step/generic/incision_manager/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != BP_MOUTH

/datum/surgery_step/generic/incision_manager/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to construct a prepared incision on and within [target]'s [BP.name] with \the [tool].",
		                     "You start to construct a prepared incision on and within [target]'s [BP.name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [BP.name] as it is pushed apart!",50, BP = BP)
	..()

/datum/surgery_step/generic/incision_manager/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has constructed a prepared incision on and within [target]'s [BP.name] with \the [tool].",
		                   "\blue You have constructed a prepared incision on and within [target]'s [BP.name] with \the [tool].")
	BP.open = 1

	if(istype(target) && target.should_have_organ(BP_HEART))
		BP.status |= ORGAN_BLEEDING

	BP.createwound(CUT, 1)
	BP.clamp()
	BP.open = 2

/datum/surgery_step/generic/incision_manager/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [BP.name] with \the [tool]!",
		                     "\red Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [BP.name] with \the [tool]!")
	BP.take_damage(20, 15, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

/datum/surgery_step/generic/cut_open
	allowed_tools = list(
		 /obj/item/weapon/scalpel = 100
		,/obj/item/weapon/kitchenknife = 75
		,/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != BP_MOUTH

/datum/surgery_step/generic/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts the incision on [target]'s [BP.name] with \the [tool].",
		                     "You start the incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [BP.name]!",40, BP = BP)
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has made an incision on [target]'s [BP.name] with \the [tool].",
		                   "\blue You have made an incision on [target]'s [BP.name] with \the [tool].",)
	BP.open = 1

	if(istype(target) && target.should_have_organ(BP_HEART))
		BP.status |= ORGAN_BLEEDING
	playsound(target, 'sound/weapons/bladeslice.ogg', 50, 1)

	BP.createwound(CUT, 1)

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!",
		                     "\red Your hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!")
	BP.take_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
		 /obj/item/weapon/hemostat = 100
		,/obj/item/weapon/cable_coil = 75
		,/obj/item/device/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/generic/clamp_bleeders/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		return BP.open && (BP.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts clamping bleeders in [target]'s [BP.name] with \the [tool].",
		                     "You start clamping bleeders in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is maddening!",40, BP = BP)
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] clamps bleeders in [target]'s [BP.name] with \the [tool].",
		                     "\blue You clamp bleeders in [target]'s [BP.name] with \the [tool].")
	BP.clamp()
	spread_germs_to_bodypart(BP, user)
	playsound(target, 'sound/items/Welder.ogg', 50, 1)

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [BP.name] with \the [tool]!",
		                     "\red Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [BP.name] with \the [tool]!")
	BP.take_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
		 /obj/item/weapon/retractor = 100
		,/obj/item/weapon/crowbar = 75
		,/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/generic/retract_skin/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		return BP.open == 1

/datum/surgery_step/generic/retract_skin/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	var/msg =  "[user] starts to pry open the incision on [target]'s [BP.name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [BP.name] with \the [tool]."
	if (target_zone == BP_CHEST)
		msg =  "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if (target_zone == BP_GROIN)
		msg =  "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [BP.name] is on fire!", 40, BP = BP)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	var/msg =  "\blue [user] keeps the incision open on [target]'s [BP.name] with \the [tool]."
	var/self_msg = "\blue You keep the incision open on [target]'s [BP.name] with \the [tool]."
	if (target_zone == BP_CHEST)
		msg =  "\blue [user] keeps the ribcage open on [target]'s torso with \the [tool]."
		self_msg = "\blue You keep the ribcage open on [target]'s torso with \the [tool]."
	if (target_zone == BP_GROIN)
		msg =  "\blue [user] keeps the incision open on [target]'s lower abdomen with \the [tool]."
		self_msg = "\blue You keep the incision open on [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	BP.open = 2

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	var/msg =  "\red [user]'s hand slips, tearing the edges of the incision on [target]'s [BP.name] with \the [tool]!"
	var/self_msg = "\red Your hand slips, tearing the edges of the incision on [target]'s [BP.name] with \the [tool]!"
	if (target_zone == BP_CHEST)
		msg =  "\red [user]'s hand slips, damaging several organs in [target]'s torso with \the [tool]!"
		self_msg = "\red Your hand slips, damaging several organs in [target]'s torso with \the [tool]!"
	if (target_zone == BP_GROIN)
		msg =  "\red [user]'s hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]"
		self_msg = "\red Your hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!"
	user.visible_message(msg, self_msg)
	BP.take_damage(12, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

/datum/surgery_step/generic/cauterize
	allowed_tools = list(
		 /obj/item/weapon/cautery = 100
		,/obj/item/clothing/mask/cigarette = 75
		,/obj/item/weapon/lighter = 50
		,/obj/item/weapon/weldingtool = 25
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(target_zone == BP_MOUTH)
		return FALSE

	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!BP)
		return FALSE

	if(BP.is_stump()) // Copypasting some stuff here to avoid having to modify ..() for a single surgery
		return (!isslime(target) && target_zone != BP_EYES && !(BP.status & ORGAN_ROBOT) && (BP.status & ORGAN_ARTERY_CUT))
	else
		return (..() && BP.open)

	//if(..())
	//	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	//	return BP.open && target_zone != BP_MOUTH

/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [BP.name] with \the [tool].",
		                   "You are beginning to cauterize the incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Your [BP.name] is being burned!",40,BP = BP)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] cauterizes the incision on [target]'s [BP.name] with \the [tool].",
		                     "\blue You cauterize the incision on [target]'s [BP.name] with \the [tool].")
	BP.open = 0
	BP.germ_level = 0
	BP.status &= ~ORGAN_BLEEDING
	if(BP.is_stump())
		BP.status &= ~ORGAN_ARTERY_CUT

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!",
		                     "\red Your hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!")
	BP.take_damage(0, 3, used_weapon = tool)

/datum/surgery_step/generic/amputate
	allowed_tools = list(
		 /obj/item/weapon/circular_saw = 100
		,/obj/item/weapon/hatchet = 75
	)

	min_duration = 110
	max_duration = 160

/datum/surgery_step/generic/amputate/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone == BP_EYES)	//there are specific steps for eye surgery
		return 0
	if (!hasbodyparts(target))
		return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP == null)
		return 0
	return !BP.cannot_amputate

/datum/surgery_step/generic/amputate/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to amputate [target]'s [BP.name] with \the [tool].",
		    "You are beginning to cut through [target]'s [BP.amputation_point] with \the [tool].")
	target.custom_pain("Your [BP.amputation_point] is being ripped apart!",100,BP = BP)
	..()

/datum/surgery_step/generic/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] amputates [target]'s [BP.name] at the [BP.amputation_point] with \the [tool].",
		                                                  "\blue You amputate [target]'s [BP.name] with \the [tool].")
	BP.droplimb(1, DROPLIMB_EDGE, user)

/datum/surgery_step/generic/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, sawing through the bone in [target]'s [BP.name] with \the [tool]!",
		                     "\red Your hand slips, sawing through the bone in [target]'s [BP.name] with \the [tool]!")
	BP.take_damage(30, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
	BP.fracture()
