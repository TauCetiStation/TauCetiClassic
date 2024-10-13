//Procedures in this file: Eye mending surgery
//////////////////////////////////////////////////////////////////
//						EYE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/eye
	clothless = 0
	priority = 2
	can_infect = 1

/datum/surgery_step/eye/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	if (BP.is_stump)
		return FALSE
	return target_zone == O_EYES

/datum/surgery_step/eye/cut_open
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/eye/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 0

/datum/surgery_step/eye/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to separate the corneas on [target]'s eyes with \the [tool].", \
	"You start to separate the corneas on [target]'s eyes with \the [tool].")
	..()

/datum/surgery_step/eye/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has separated the corneas on [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You have separated the corneas on [target]'s eyes with \the [tool].</span>",)
	target.op_stage.eyes = 1
	target.blinded += 1.5

/datum/surgery_step/eye/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s eyes wth \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, slicing [target]'s eyes wth \the [tool]!</span>" )
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(5, 0)

/datum/surgery_step/eye/lift_eyes
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,	        \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/eye/lift_eyes/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 1

/datum/surgery_step/eye/lift_eyes/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts lifting corneas from [target]'s eyes with \the [tool].", \
	"You start lifting corneas from [target]'s eyes with \the [tool].")
	..()

/datum/surgery_step/eye/lift_eyes/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has lifted the corneas from [target]'s eyes from with \the [tool].</span>" , \
	"<span class='notice'>You has lifted the corneas from [target]'s eyes from with \the [tool].</span>" )
	target.op_stage.eyes = 2

/datum/surgery_step/eye/lift_eyes/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging [target]'s eyes with \the [tool]!</span>")
	BP.take_damage(10, 0, used_weapon = tool)
	IO.take_damage(5, 0)

/datum/surgery_step/eye/mend_eyes
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,             \
	/obj/item/stack/cable_coil = 75,            \
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 10	//I don't know. Don't ask me. But I'm leaving it because hilarity.
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/eye/mend_eyes/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 2

/datum/surgery_step/eye/mend_eyes/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending the nerves and lenses in [target]'s eyes with \the [tool].", \
	"You start mending the nerves and lenses in [target]'s eyes with the [tool].")
	..()

/datum/surgery_step/eye/mend_eyes/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/eyes = target.organs_by_name[O_EYES]
	user.visible_message("<span class='notice'>[user] mends the nerves and lenses in [target]'s with \the [tool].</span>" ,	\
	"<span class='notice'>You mend the nerves and lenses in [target]'s with \the [tool].</span>")

	target.cure_nearsighted(list(EYE_DAMAGE_TRAIT, EYE_DAMAGE_TEMPORARY_TRAIT))
	target.sdisabilities &= ~BLIND
	eyes.damage = 0

/datum/surgery_step/eye/mend_eyes/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, stabbing \the [tool] into [target]'s eye!</span>", \
	"<span class='warning'>Your hand slips, stabbing \the [tool] into [target]'s eye!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(5, 0)

/datum/surgery_step/eye/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/eye/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision around [target]'s eyes with \the [tool]." , \
	"You are beginning to cauterize the incision around [target]'s eyes with \the [tool].")

/datum/surgery_step/eye/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cauterizes the incision around [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision around [target]'s eyes with \the [tool].</span>")

	target.op_stage.eyes = 0

/datum/surgery_step/eye/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips,  searing [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, searing [target]'s eyes with \the [tool]!</span>")
	BP.take_damage(0, 5, used_weapon = tool)
	IO.take_damage(5, 0)

//////////////////////////////////////////////////////////////////
//						EYE SURGERY manipulation				//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/eye/manipulation
	priority = 1
	allowed_species = null
	var/obj/item/organ/internal/I = null

/datum/surgery_step/eye/manipulation/place
	allowed_tools = list(/obj/item/organ/internal = 100)

	min_duration = 110
	max_duration = 150


/datum/surgery_step/eye/manipulation/place/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
    if(!ishuman(target))
        return FALSE



    var/obj/item/organ/internal/I = tool
    if(I.requires_robotic_bodypart)
        user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
        return FALSE

    if(target_zone != I.parent_bodypart || target.get_organ_slot(I.slot))
        user.visible_message ( "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
        return FALSE

    if(I.damage > (I.max_damage * 0.75))
        user.visible_message ( "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
        return FALSE

    if(target.get_int_organ(I))
        user.visible_message ( "<span class='warning'> \The [target] already has [I].</span>")
        return FALSE

    return TRUE



/datum/surgery_step/eye/manipulation/place/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
		"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")
	..()

/datum/surgery_step/eye/manipulation/place/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends the nerves and lenses in [target]'s with \the [tool].</span>" ,	\
	"<span class='notice'>You mend the nerves and lenses in [target]'s with \the [tool].</span>")

	I = tool
	user.drop_from_inventory(tool)
	I.insert_organ(target)
	user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target].</span>", \
	"<span class='notice'> You have transplanted \the [tool] into [target].</span>")
	I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/eye/manipulation/place/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, stabbing \the [tool] into [target]'s eye!</span>", \
	"<span class='warning'>Your hand slips, stabbing \the [tool] into [target]'s eye!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	if(IO)
		IO.take_damage(5, 0)

//////////////////////////////////////////////////////////////////
//				EYE SURGERY manipulation for eyes				//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/organ_manipulation/place_eye
	priority = 2
	allowed_tools = list(/obj/item/organ/internal/eyes = 100)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/organ_manipulation/place_eye/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
    if(!ishuman(target))
        return FALSE

    if(target_zone != O_EYES)
        return FALSE


    var/obj/item/organ/internal/I = tool
    if(I.requires_robotic_bodypart)
        user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
        return FALSE

    if(target.get_organ_slot(I.slot))
        user.visible_message ( "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
        return FALSE

    if(I.damage > (I.max_damage * 0.75))
        user.visible_message ( "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
        return FALSE

    if(target.get_int_organ(I))
        user.visible_message ( "<span class='warning'> \The [target] already has [I].</span>")
        return FALSE

    return TRUE


/datum/surgery_step/organ_manipulation/place_eye/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
		"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")

	..()

/datum/surgery_step/organ_manipulation/place_eye/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	I = tool
	user.drop_from_inventory(tool)
	I.insert_organ(target)
	user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target].</span>", \
	"<span class='notice'> You have transplanted \the [tool] into [target].</span>")
	I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/organ_manipulation/place_eye/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/eye/manipulation/remove
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/eye/manipulation/remove/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 2

/datum/surgery_step/eye/manipulation/remove/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts disconnect eyes inside the incision on [target]'s [BP.name] with \the [tool].", \
	"You start disconnect eyes inside the incision on [target]'s [BP.name] with \the [tool]" )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/eye/manipulation/remove/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.bodypart_organs.len)
		var/list/embed_organs = list()
		for(var/embed_organ in BP.bodypart_organs)
			embed_organs += embed_organ
		for(var/atom/embed_organ as anything in embed_organs)
			embed_organs[embed_organ] = image(icon = embed_organ.icon, icon_state = embed_organ.icon_state)
		var/choosen_organ = show_radial_menu(user, target, embed_organs, radius = 50, require_near = TRUE, tooltips = TRUE)
		if(!choosen_organ)
			user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>")
			return
		var/obj/item/organ/internal/I = choosen_organ
		I.status |= ORGAN_CUT_AWAY
		I.remove(target)
		I.loc = get_turf(target)
		BP.bodypart_organs  -= I
		playsound(target, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)

/datum/surgery_step/eye/manipulation/remove/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, stabbing \the [tool] into [target]'s eye!</span>", \
	"<span class='warning'>Your hand slips, stabbing \the [tool] into [target]'s eye!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	if(IO)
		IO.take_damage(5, 0)

//////////////////////////////////////////////////////////////////
//						ROBO EYE SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc/eye
	clothless = FALSE
	priority = 2
	can_infect = FALSE

	allowed_species = list(IPC)

/datum/surgery_step/ipc/eye/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!BP)
		return FALSE
	return target_zone == O_EYES

/datum/surgery_step/ipc/eye/screw_open
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/ipc/eye/screw_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 0

/datum/surgery_step/ipc/eye/screw_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to unscrew [target]'s camera panels with \the [tool].",
	"You unscrew [target]'s camera panels with \the [tool].")
	..()

/datum/surgery_step/ipc/eye/screw_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] unscrewed [target]'s camera panels with \the [tool].</span>" ,
	"<span class='notice'>You unscrewed [target]'s camera panels with \the [tool].</span>")
	target.op_stage.eyes = 1
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "<span class='warning italics'>%VISUALS DENIED%. REQUESTING ADDITIONAL PERSPECTION REACTIONS.</span>")
	target.blinded += 1.5

/datum/surgery_step/ipc/eye/screw_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s cameras wth \the [tool]!</span>" ,
	"<span class='warning'>Your hand slips, scratching [target]'s cameras wth \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(5, 0)

/datum/surgery_step/ipc/eye/mend_cameras
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ipc/eye/mend_cameras/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 1

/datum/surgery_step/ipc/eye/mend_cameras/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending lenses and wires in [target]'s cameras with \the [tool].",
	"You start mending lenses and wires in [target]'s cameras with the [tool].")
	..()

/datum/surgery_step/ipc/eye/mend_cameras/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends the lenses and wires in [target]'s cameras with \the [tool].</span>",
	"<span class='notice'>You mend the lenses abd wires in [target]'s cameras with \the [tool].</span>")
	target.op_stage.eyes = 2

/datum/surgery_step/ipc/eye/mend_cameras/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s cameras with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, denting [target]'s cameras with \the [tool]!</span>")
	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/nanopaste) || istype(tool, /obj/item/weapon/bonegel))
		BP.take_damage(0, 6, used_weapon = tool)

	else if(iswrenching(tool))
		BP.take_damage(12, 0, used_weapon = tool)
		BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(dam_amt,0)
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "<span class='warning italics'>SEVERE VISUAL SENSOR DAMAGE DETECTED. %REACTION_OVERLOAD%.</span>")
	target.blinded += 3.0

/datum/surgery_step/ipc/eye/close_shut
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/ipc/eye/close_shut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes != 0

/datum/surgery_step/ipc/eye/close_shut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to lock [target]'s camera panels with \the [tool]." ,
	"You are beginning to lock [target]'s camera panels with \the [tool].")

/datum/surgery_step/ipc/eye/close_shut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/eyes = target.organs_by_name[O_EYES]
	user.visible_message("<span class='notice'>[user] locks [target]'s camera panels with \the [tool].</span>",
	"<span class='notice'>You lock [target]'s camera panels with \the [tool].</span>")
	if (target.op_stage.eyes == 2)
		target.cure_nearsighted(EYE_DAMAGE_TRAIT)
		target.sdisabilities &= ~BLIND
		eyes.damage = 0
	target.op_stage.eyes = 0

/datum/surgery_step/ipc/eye/close_shut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips,  denting [target]'s cameras with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, denting [target]'s cameras with \the [tool]!</span>")
	BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)
	IO.take_damage(5, 0)
