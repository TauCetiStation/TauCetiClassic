//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic
	can_infect = 1

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!ishuman(target))
		return FALSE
	if (target_zone == O_EYES)	//there are specific steps for eye surgery
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return FALSE
	if (BP.is_stump)
		return FALSE
	if (!BP.is_flesh())
		return FALSE
	return TRUE

/datum/surgery_step/generic/cut_with_laser
	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 95, \
	/obj/item/weapon/scalpel/laser2 = 85, \
	/obj/item/weapon/scalpel/laser1 = 75, \
	/obj/item/weapon/melee/energy/sword = 5
	)

	priority = 2
	min_duration = 70
	max_duration = 90

/datum/surgery_step/generic/cut_with_laser/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != O_MOUTH

/datum/surgery_step/generic/cut_with_laser/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts the bloodless incision on [target]'s [BP.name] with \the [tool].", \
	"You start the bloodless incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [BP.name]!",1)
	..()

/datum/surgery_step/generic/cut_with_laser/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has made a bloodless incision on [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You have made a bloodless incision on [target]'s [BP.name] with \the [tool].</span>",)
	//Could be cleaner ...
	BP.open = 1
	BP.take_damage(1, 1, DAM_SHARP|DAM_EDGE, tool)
	BP.strap()

/datum/surgery_step/generic/cut_with_laser/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips as the blade sputters, searing a long gash in [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips as the blade sputters, searing a long gash in [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(7.5, 12.5, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/generic/incision_manager
	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 100
	)

	priority = 2
	min_duration = 80
	max_duration = 120

/datum/surgery_step/generic/incision_manager/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != O_MOUTH

/datum/surgery_step/generic/incision_manager/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to construct a prepared incision on and within [target]'s [BP.name] with \the [tool].", \
	"You start to construct a prepared incision on and within [target]'s [BP.name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [BP.name] as it is pushed apart!",1)
	..()

/datum/surgery_step/generic/incision_manager/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has constructed a prepared incision on and within [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You have constructed a prepared incision on and within [target]'s [BP.name] with \the [tool].</span>",)
	BP.open = 1
	BP.status |= ORGAN_BLEEDING
	BP.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)
	BP.strap()
	BP.open = 2

/datum/surgery_step/generic/incision_manager/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 15, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/generic/cut_open
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != O_MOUTH

/datum/surgery_step/generic/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts the incision on [target]'s [BP.name] with \the [tool].", \
	"You start the incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [BP.name]!",1)
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [BP.name] with \the [tool].</span>",)
	BP.open = 1
	BP.status |= ORGAN_BLEEDING
	BP.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [BP.name] in the wrong place with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,             \
	/obj/item/stack/cable_coil = 75,            \
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/generic/clamp_bleeders/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open && (BP.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts clamping bleeders in [target]'s [BP.name] with \the [tool].", \
	"You start clamping bleeders in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is maddening!",1)
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [BP.name] with \the [tool].</span>",	\
	"<span class='notice'>You clamp bleeders in [target]'s [BP.name] with \the [tool].</span>")
	BP.strap()

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [BP.name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [BP.name] with \the [tool]!</span>",)
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/generic/retract_skin/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 1 && !(BP.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/retract_skin/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [BP.name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [BP.name] with \the [tool]."
	if (target_zone == BP_CHEST)
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if (target_zone == BP_GROIN)
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [BP.name] is on fire!",1)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
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

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of the incision on [target]'s [BP.name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, tearing the edges of the incision on [target]'s [BP.name] with \the [tool]!</span>"
	if (target_zone == BP_CHEST)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>"
	if (target_zone == BP_GROIN)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	BP.take_damage(12, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/stack/medical/suture = 100,
	/obj/item/weapon/cautery = 100,
	/obj/item/clothing/mask/cigarette = 75,
	/obj/item/weapon/lighter = 50,
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open && target_zone != O_MOUTH

/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [BP.name] with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Your [BP.name] is being burned!",1)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s [BP.name] with \the [tool].</span>")
	BP.open = 0
	BP.status &= ~ORGAN_BLEEDING

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(0, 3, used_weapon = tool)

/datum/surgery_step/generic/cut_limb
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 110
	max_duration = 160
	allowed_species = null

/datum/surgery_step/generic/cut_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone == O_EYES) // there are specific steps for eye surgery
		return 0
	if (!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	return target_zone != BP_CHEST && target_zone != BP_GROIN && target_zone != BP_HEAD

/datum/surgery_step/generic/cut_limb/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to cut off [target]'s [BP.name] with \the [tool]." , \
	"You are beginning to cut off [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Your [BP.name] is being ripped apart!",1)
	..()

/datum/surgery_step/generic/cut_limb/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cuts off [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You cut off [target]'s [BP.name] with \the [tool].</span>")
	BP.droplimb(null, TRUE)

/datum/surgery_step/generic/cut_limb/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawwing through the bone in [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawwing through the bone in [target]'s [BP.name] with \the [tool]!</span>")
	BP.fracture()
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)
//////////////////////////////////////////////////////////////////
//						COMMON ROBOTIC STEPS					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ipcgeneric
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipcgeneric/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(target_zone == O_EYES)	//there are specific steps for eye surgery
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!BP)
		return FALSE
	if(BP.is_stump)
		return FALSE
	return TRUE

/datum/surgery_step/ipcgeneric/screw_open
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/ipcgeneric/screw_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != O_MOUTH

/datum/surgery_step/ipcgeneric/screw_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to unscrew [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You start to unscrew [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "%[BP.name]'S MAINTENANCE HATCH% UNATHORISED ACCESS ATTEMPT DETECTED!")
	..()

/datum/surgery_step/ipcgeneric/screw_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has loosen bolts on [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You have unscrewed [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",)
	BP.open = 1
	BP.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipcgeneric/screw_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipcgeneric/pry_open
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ipcgeneric/pry_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 1

/datum/surgery_step/ipcgeneric/pry_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to pry open [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You start to pry open [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "%[BP.name]'s MAINTENANCE HATCH% DAMAGE DETECTED. CEASE APPLIED DAMAGE.")
	..()

/datum/surgery_step/ipcgeneric/pry_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] pries open [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You pry open [target]'s [BP.name]'s maintenace hatch with \the [tool].</span>")
	BP.open = 2

/datum/surgery_step/ipcgeneric/pry_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(12, 0, used_weapon = tool)

/datum/surgery_step/ipcgeneric/close_shut
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/ipcgeneric/close_shut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open && target_zone != O_MOUTH

/datum/surgery_step/ipcgeneric/close_shut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to lock [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You are beginning to lock [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	..()

/datum/surgery_step/ipcgeneric/close_shut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] locks [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You lock [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>")
	BP.open = 0

/datum/surgery_step/ipcgeneric/close_shut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, denting [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)
