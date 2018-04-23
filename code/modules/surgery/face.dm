//Procedures in this file: Facial reconstruction surgery
//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/face
	clothless = 0
	priority = 2
	can_infect = 0

/datum/surgery_step/face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	return target_zone == O_MOUTH

/datum/surgery_step/generic/cut_face
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target_zone == O_MOUTH && target.op_stage.face == 0

/datum/surgery_step/generic/cut_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to cut open [target]'s face and neck with \the [tool].", \
	"You start to cut open [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/generic/cut_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] has cut open [target]'s face and neck with \the [tool]." , \
	"\blue You have cut open [target]'s face and neck with \the [tool].",)
	target.op_stage.face = 1

/datum/surgery_step/generic/cut_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, slicing [target]'s throat wth \the [tool]!" , \
	"\red Your hand slips, slicing [target]'s throat wth \the [tool]!" )
	BP.createwound(CUT, 60)
	target.losebreath += 10

/datum/surgery_step/face/mend_vocal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,             \
	/obj/item/stack/cable_coil = 75,            \
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 10	//I don't know. Don't ask me. But I'm leaving it because hilarity.
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/face/mend_vocal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.op_stage.face == 1

/datum/surgery_step/face/mend_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
	"You start mending [target]'s vocal cords with \the [tool].")
	..()

/datum/surgery_step/face/mend_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] mends [target]'s vocal cords with \the [tool].", \
	"\blue You mend [target]'s vocal cords with \the [tool].")
	target.op_stage.face = 2

/datum/surgery_step/face/mend_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!", \
	"\red Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!")
	target.losebreath += 10

/datum/surgery_step/face/fix_face
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/face/fix_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.op_stage.face == 2

/datum/surgery_step/face/fix_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts pulling the skin on [target]'s face back in place with \the [tool].", \
	"You start pulling the skin on [target]'s face back in place with \the [tool].")
	..()

/datum/surgery_step/face/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] pulls the skin on [target]'s face back in place with \the [tool].",	\
	"\blue You pull the skin on [target]'s face back in place with \the [tool].")
	target.op_stage.face = 3

/datum/surgery_step/face/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, tearing skin on [target]'s face with \the [tool]!", \
	"\red Your hand slips, tearing skin on [target]'s face with \the [tool]!")
	target.apply_damage(10, BRUTE, BP, null, DAM_SHARP | DAM_EDGE)

/datum/surgery_step/face/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/face/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.op_stage.face > 0

/datum/surgery_step/face/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/face/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] cauterizes the incision on [target]'s face and neck with \the [tool].", \
	"\blue You cauterize the incision on [target]'s face and neck with \the [tool].")
	BP.open = 0
	BP.status &= ~ORGAN_BLEEDING
	if (target.op_stage.face == 3)
		var/obj/item/organ/external/head/H = BP
		H.disfigured = 0
	target.op_stage.face = 0

/datum/surgery_step/face/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!", \
	"\red Your hand slips, leaving a small burn on [target]'s face with \the [tool]!")
	target.apply_damage(4, BURN, BP)
//////////////////////////////////////////////////////////////////
//				ROBOTIC FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc_face
	clothless = FALSE
	priority = 2
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipc_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(!(target.species && target.species.flags[IS_SYNTHETIC]))
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return FALSE
	return target_zone == O_MOUTH

/datum/surgery_step/ipcgeneric/screw_face
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/ipcgeneric/screw_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(!(target.species && target.species.flags[IS_SYNTHETIC]))
		return FALSE
	return ..() && target_zone == O_MOUTH && target.op_stage.face == 0

/datum/surgery_step/ipcgeneric/screw_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to unscrew [target]'s screen with \the [tool].",
	"You start to unscrew [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipcgeneric/screw_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has loosen bolts on [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You have unscrewed [target]'s screen with \the [tool].</span>")
	target.op_stage.face = 1
	target.update_hair()

/datum/surgery_step/ipcgeneric/screw_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s screen with \the [tool]!</span>")
	BP.createwound(CUT, 60)

/datum/surgery_step/ipc_face/pry_screen
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ipc_face/pry_screen/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 1

/datum/surgery_step/ipc_face/pry_screen/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to pry open [target]'s screen with \the [tool].",
	"You start to pry open [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc_face/pry_screen/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pries open [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You pry open [target]'s screen with \the [tool].</span>")
	target.op_stage.face = 2

/datum/surgery_step/ipc_face/pry_screen/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s screen with \the [tool]!</span>")
	target.apply_damage(12, BRUTE, BP, null)

/datum/surgery_step/ipc_face/hack_face
	allowed_tools = list(
	/obj/item/device/multitool = 100,
	/obj/item/device/assembly/signaler = 75
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ipc_face/hack_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 2

/datum/surgery_step/ipc_face/hack_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting coloration on [target]'s screen with \the [tool].",
	"You start adjusting coloration on [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc_face/hack_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] changes coloration on [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You change coloration on [target]'s screen with \the [tool].</span>")
	var/list/species_hair = list()
	for(var/i in hair_styles_list)
		var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
		if(target.species.name in tmp_hair.species_allowed)
			species_hair += i
	var/new_style = input(user, "Select a screen color scheme", "Changing")  as null|anything in species_hair
	if(new_style)
		target.h_style = new_style
		target.update_hair()

/datum/surgery_step/ipc_face/hack_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s screen with \the [tool]!</span>")
	target.apply_damage(10, BRUTE, BP)

/datum/surgery_step/ipc_face/fix_screen
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/ipc_face/fix_screen/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 2

/datum/surgery_step/ipc_face/fix_screen/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending the mechanisms under [target]'s screen with \the [tool].",
	"You start mending the mechanisms under [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc_face/fix_screen/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] repairs [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You repair [target]'s screen with \the [tool].</span>" )
	target.op_stage.face = 3

/datum/surgery_step/ipc_face/fix_screen/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] on [target]'s screen, denting it up!</span>",
	"<span class='warning'>Your hand slips, smearing [tool] on [target]'s screen, denting it up!</span>")
	if(istype(tool, /obj/item/stack/nanopaste) || istype(tool, /obj/item/weapon/bonegel))
		target.apply_damage(6, BURN, BP, null)

	else if(istype(tool, /obj/item/weapon/wrench))
		target.apply_damage(12, BRUTE, BP, null)
		BP.createwound(CUT, 5)

/datum/surgery_step/ipc_face/close_shut
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/ipc_face/close_shut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face > 0

/datum/surgery_step/ipc_face/close_shut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to lock in place [target]'s screen with \the [tool].",
	"You are beginning to lock in place [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc_face/close_shut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] locks in place [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You lock in place [target]'s screen \the [tool].</span>")
	BP.open = 0
	if (target.op_stage.face == 3)
		var/obj/item/organ/external/head/H = BP
		H.disfigured = FALSE
	target.op_stage.face = 0

/datum/surgery_step/ipc_face/close_shut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small dent on [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, leaving a small dent on [target]'s screen with \the [tool]!</span>")
	target.apply_damage(6, BRUTE, BP)
