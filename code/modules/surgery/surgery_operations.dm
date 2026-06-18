//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/glue_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/stack/rods = 50
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && BP.stage == 0

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.stage == 0)
		user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [BP.name] with \the [tool]." , \
		"You start applying medication to the damaged bones in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] applies some [tool] to [target]'s bone in [BP.name]</span>", \
		"<span class='notice'>You apply some [tool] to [target]'s bone in [BP.name] with \the [tool].</span>")
	BP.stage = 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")

/datum/surgery_step/set_bone
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.body_zone != BP_HEAD && BP.open >= 2 && BP.stage == 1

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to set the bone in [target]'s [BP.name] in place with \the [tool]." , \
		"You are beginning to set the bone in [target]'s [BP.name] in place with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is going to make you pass out!",1)
	..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.status & ORGAN_BROKEN)
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [BP.name] in place with \the [tool].</span>", \
			"<span class='notice'>You set the bone in [target]'s [BP.name] in place with \the [tool].</span>")
		BP.stage = 2
	else
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [BP.name]<span class='warning'> in the WRONG place with \the [tool].</span></span>", \
			"<span class='notice'>You set the bone in [target]'s [BP.name]<span class='warning'> in the WRONG place with \the [tool].</span></span>")
		BP.fracture()

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the bone in [target]'s [BP.name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, damaging the bone in [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)

/datum/surgery_step/mend_skull
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.body_zone == BP_HEAD && BP.open >= 2 && BP.stage == 1

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to piece together [target]'s skull with \the [tool]."  , \
		"You are beginning to piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] sets [target]'s skull with \the [tool].</span>" , \
		"<span class='notice'>You set [target]'s skull with \the [tool].</span>")
	BP.stage = 2

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
	var/obj/item/organ/external/head/H = BP
	H.take_damage(10, 0, used_weapon = tool)
	H.disfigured = 1

/datum/surgery_step/finish_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/stack/rods = 50
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && BP.stage == 2

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [BP.name] with \the [tool].", \
	"You start to finish mending the damaged bones in [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has mended the damaged bones in [target]'s [BP.name] with \the [tool].</span>"  , \
		"<span class='notice'>You have mended the damaged bones in [target]'s [BP.name] with \the [tool].</span>" )
	BP.status &= ~(ORGAN_BROKEN | ORGAN_SPLINTED)
	BP.stage = 0
	BP.perma_injury = 0

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")

//Procedures in this file: Brain extraction. Brain fixing. Slime Core extraction.
//////////////////////////////////////////////////////////////////
//						BRAIN SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain
	clothless = 0
	priority = 2
	blood_level = 1

/datum/surgery_step/brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!ishuman(target))
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(isnull(BP))
		return FALSE
	return target_zone == BP_HEAD && BP.open

/datum/surgery_step/brain/saw_skull
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/brain/saw_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 0

/datum/surgery_step/brain/saw_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cut through [target]'s skull with \the [tool].",
	"You begin to cut through [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/brain/saw_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has cut [target]'s skull open with \the [tool].</span>",
	"<span class='notice'>You have cut [target]'s skull open with \the [tool].</span>")
	target.op_stage.skull = 1

/datum/surgery_step/brain/saw_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s skull with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, cracking [target]'s skull with \the [tool]!</span>" )
	BP.fracture()
	BP.take_damage(max(10, tool.force), 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/brain/cut_brain
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)
	allowed_species = list("exclude", IPC, DIONA)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/brain/cut_brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 1 && target.has_brain() && target.op_stage.brain_cut == 0

/datum/surgery_step/brain/cut_brain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts separating connections to [target]'s brain with \the [tool].",
	"You start separating connections to [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/cut_brain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] separates connections to [target]'s brain with \the [tool].</span>",
	"<span class='notice'>You separate connections to [target]'s brain with \the [tool].</span>")
	target.op_stage.brain_cut = 1

/datum/surgery_step/brain/cut_brain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>")
	BP.take_damage(50, 0, DAM_SHARP|DAM_EDGE,  tool)

/datum/surgery_step/brain/saw_spine
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/brain/saw_spine/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 1 && target.has_brain() && target.op_stage.brain_cut == 1

/datum/surgery_step/brain/saw_spine/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts separating [target]'s brain from \his spine with \the [tool].",
	"You start separating [target]'s brain from spine with \the [tool].")
	..()

/datum/surgery_step/brain/saw_spine/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] separates [target]'s brain from \his spine with \the [tool].</span>",
	"<span class='notice'>You separate [target]'s brain from spine with \the [tool].</span>")

	var/mob/living/simple_animal/borer/borer = target.has_brain_worms()

	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR

	target.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")
	SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, target)

	var/obj/item/organ/internal/brain/IO = target.organs_by_name[O_BRAIN]
	IO.status |= ORGAN_CUT_AWAY
	IO.remove(target)
	IO.loc = get_turf(target)
	target.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

/datum/surgery_step/brain/saw_spine/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, cutting a vein in [target]'s brain with \the [tool]!</span>")
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)
	if (ishuman(user))
		user:bloody_body(target)
		user:bloody_hands(target, 0)

/datum/surgery_step/brain/insert_brain
	allowed_tools = list(
	/obj/item/organ/internal/brain = 100
	)
	allowed_species = list("exclude", IPC, DIONA)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/brain/insert_brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/internal/I = tool
	if(!(target.get_species() in I.compability))
		user.visible_message ( "<span class='warning'> \The [I] not compability to [target]</span>")
		return FALSE

	if(I.requires_robotic_bodypart)
		user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
		return FALSE

	return ..() && target.op_stage.skull == 1 && !target.has_brain()

/datum/surgery_step/brain/insert_brain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts inserting [tool] into [target]'s [BP.name].",
	"You start inserting [tool] into [target]'s [BP.name].")
	..()

/datum/surgery_step/brain/insert_brain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] inserts [tool] into [target]'s [BP.name].</span>",
	"<span class='notice'>You inserts [tool] into [target]'s [BP.name].</span>")

	if(!istype(tool, /obj/item/organ/internal/brain))
		return

	var/obj/item/organ/internal/brain/B = tool
	if(target.get_int_organ(B))
		user.visible_message ( "<span class='warning'> \The [target] already has [B].</span>")
		return FALSE

	//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
	if(target.key)//Revised. /N
		target.ghostize()
	if(B.brainmob)
		if(B.brainmob.mind)
			B.brainmob.mind.transfer_to(target)
		else
			target.key = B.brainmob.key
		target.dna = B.brainmob.dna
	user.drop_from_inventory(tool)
	B.insert_organ(target)
	target.timeofdeath = min(target.timeofdeath, world.time - DEFIB_TIME_LIMIT) // so they cannot be defibbed
	ADD_TRAIT(target, TRAIT_NO_CLONE, GENERIC_TRAIT) // so they cannot be cloned


/datum/surgery_step/brain/insert_brain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s [BP.name] with \the [tool]!</span>")
	target.apply_damage(5, BRUTE, BP)

//////////////////////////////////////////////////////////////////
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/bone_chips
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,
	/obj/item/weapon/wirecutters = 75,
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/brain/bone_chips/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull ==  1 && target.has_brain() && target.op_stage.brain_fix == 0

/datum/surgery_step/brain/bone_chips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts taking bone chips out of [target]'s brain with \the [tool].",
	"You start taking bone chips out of [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/bone_chips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] takes out all the bone chips in [target]'s brain with \the [tool].</span>",
	"<span class='notice'>You take out all the bone chips in [target]'s brain with \the [tool].</span>")
	target.op_stage.brain_fix = 1


/datum/surgery_step/brain/bone_chips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, jabbing \the [tool] in [target]'s brain!</span>",
	"<span class='warning'>Your hand slips, jabbing \the [tool] in [target]'s brain!</span>")
	BP.take_damage(30, 0, DAM_SHARP, tool)

/datum/surgery_step/brain/hematoma
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100,
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/brain/hematoma/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 1 && target.has_brain() && target.op_stage.brain_fix == 1

/datum/surgery_step/brain/hematoma/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending hematoma in [target]'s brain with \the [tool].",
	"You start mending hematoma in [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/hematoma/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends hematoma in [target]'s brain with \the [tool].</span>",
	"<span class='notice'>You mend hematoma in [target]'s brain with \the [tool].</span>")
	var/obj/item/organ/internal/brain/IO = target.organs_by_name[O_BRAIN]
	if (IO)
		IO.damage = 0


/datum/surgery_step/brain/hematoma/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, bruising [target]'s brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, bruising [target]'s brain with \the [tool]!</span>")
	BP.take_damage(20, 0, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//				mend skull surgery step
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/mend_skull
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,
	/obj/item/stack/rods = 50
	)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/brain/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 1

/datum/surgery_step/brain/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts applying \the [tool] to [target]'s skull.",
	"[user] starts applying \the [tool] to [target]'s skull.")
	..()

/datum/surgery_step/brain/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] applied \the [tool] to [target]'s skull.</span>",
	"<span class='notice'>You applied \the [tool] to [target]'s skull.</span>")
	target.op_stage.skull = 0
	target.op_stage.brain_cut = 0
	target.op_stage.brain_fix = 0

/datum/surgery_step/brain/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" ,
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")

//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return isslime(target) && target.stat == DEAD

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_flesh/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.brain_cut == 0

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].",
	"You start cutting through [target]'s flesh with \the [tool].")

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts through [target]'s flesh with \the [tool].</span>",
	"<span class='notice'>You cut through [target]'s flesh with \the [tool], exposing the cores.</span>")
	target.op_stage.brain_cut = 1

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing [target]'s flesh with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, tearing [target]'s flesh with \the [tool]!</span>")

/datum/surgery_step/slime/cut_innards
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_innards/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.brain_cut == 1

/datum/surgery_step/slime/cut_innards/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].",
	"You start cutting [target]'s silky innards apart with \the [tool].")

/datum/surgery_step/slime/cut_innards/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts [target]'s innards apart with \the [tool], exposing the cores.</span>",
	"<span class='notice'>You cut [target]'s innards apart with \the [tool], exposing the cores.</span>")
	target.op_stage.brain_cut = 2

/datum/surgery_step/slime/cut_innards/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing [target]'s innards with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, tearing [target]'s innards with \the [tool]!</span>")

/datum/surgery_step/slime/saw_core
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/slime/saw_core/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.brain_cut == 2 && target.cores > 0

/datum/surgery_step/slime/saw_core/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].",
	"You start cutting out one of [target]'s cores with \the [tool].")

/datum/surgery_step/slime/saw_core/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	target.cores--
	user.visible_message("<span class='notice'>[user] cuts out one of [target]'s cores with \the [tool].</span>",
	"<span class='notice'>You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.</span>")

	if(target.cores >= 0)
		new target.coretype(target.loc)
	if(target.cores <= 0)
		var/origstate = initial(target.icon_state)
		target.icon_state = "[origstate] dead-nocore"


/datum/surgery_step/slime/saw_core/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, causing \him to miss the core!</span>",
	"<span class='warning'>Your hand slips, causing you to miss the core!</span>")

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
	var/obj/item/organ/internal/eyes/IO = target.organs_by_name[O_EYES]
	if(!IO)
		return
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
//				EYE SURGERY manipulation for eyes				//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/organ_manipulation/place_eye
	priority = 2
	allowed_tools = list(/obj/item/organ/internal/eyes = 100)

	allowed_species = list("exclude", IPC, DIONA)

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
	var/obj/item/organ/internal/I = tool
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

	allowed_species = list("exclude", IPC, DIONA)

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
		var/obj/item/organ/internal/eyes/eyes = target.organs_by_name[O_EYES]
		if(eyes)
			eyes.status |= ORGAN_CUT_AWAY
			eyes.remove(target)
			eyes.loc = get_turf(target)
			BP.bodypart_organs  -= eyes
			playsound(target, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
		if(!eyes)
			user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>")
			return


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
	if (BP.is_stump)
		return FALSE
	return target_zone == O_MOUTH

/datum/surgery_step/face/cut_face
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/face/cut_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 0

/datum/surgery_step/face/cut_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to cut open [target]'s face and neck with \the [tool].", \
	"You start to cut open [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/face/cut_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has cut open [target]'s face and neck with \the [tool].</span>" , \
	"<span class='notice'>You have cut open [target]'s face and neck with \the [tool].</span>",)
	target.op_stage.face = 1

/datum/surgery_step/face/cut_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s throat wth \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, slicing [target]'s throat wth \the [tool]!</span>" )
	BP.take_damage(60, 0, DAM_SHARP|DAM_EDGE, tool)
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
	return ..() && target.op_stage.face == 1

/datum/surgery_step/face/mend_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
	"You start mending [target]'s vocal cords with \the [tool].")
	..()

/datum/surgery_step/face/mend_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends [target]'s vocal cords with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s vocal cords with \the [tool].</span>")
	target.op_stage.face = 2

/datum/surgery_step/face/mend_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
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
	return ..() && target.op_stage.face == 2

/datum/surgery_step/face/fix_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts pulling the skin on [target]'s face back in place with \the [tool].", \
	"You start pulling the skin on [target]'s face back in place with \the [tool].")
	..()

/datum/surgery_step/face/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pulls the skin on [target]'s face back in place with \the [tool].</span>",	\
	"<span class='notice'>You pull the skin on [target]'s face back in place with \the [tool].</span>")
	target.op_stage.face = 3

/datum/surgery_step/face/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

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
	return ..() && target.op_stage.face > 0

/datum/surgery_step/face/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/face/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s face and neck with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s face and neck with \the [tool].</span>")
	BP.open = 0
	BP.status &= ~ORGAN_BLEEDING
	if (target.op_stage.face == 3)
		var/obj/item/organ/external/head/H = BP
		H.disfigured = 0
	target.op_stage.face = 0

/datum/surgery_step/face/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>")
	BP.take_damage(0, 4, used_weapon = tool)
//////////////////////////////////////////////////////////////////
//				ROBOTIC FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc/face
	clothless = FALSE
	priority = 2
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipc/face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return FALSE
	return target_zone == O_MOUTH

/datum/surgery_step/ipc/face/screw_face
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/ipc/face/screw_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 0

/datum/surgery_step/ipc/face/screw_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to unscrew [target]'s screen with \the [tool].",
	"You start to unscrew [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc/face/screw_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has loosen bolts on [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You have unscrewed [target]'s screen with \the [tool].</span>")
	target.op_stage.face = 1
	// target.update_body(BP_HEAD) // commenting this out as at this moment head appearance does not changes based on op stage

/datum/surgery_step/ipc/face/screw_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s screen with \the [tool]!</span>")
	BP.take_damage(6, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc/face/pry_screen
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ipc/face/pry_screen/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 1

/datum/surgery_step/ipc/face/pry_screen/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to pry open [target]'s screen with \the [tool].",
	"You start to pry open [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc/face/pry_screen/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pries open [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You pry open [target]'s screen with \the [tool].</span>")
	target.op_stage.face = 2

/datum/surgery_step/ipc/face/pry_screen/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s screen with \the [tool]!</span>")
	BP.take_damage(12, 0, used_weapon = tool)

/datum/surgery_step/ipc/face/fix_screen
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/ipc/face/fix_screen/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 2

/datum/surgery_step/ipc/face/fix_screen/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending the mechanisms under [target]'s screen with \the [tool].",
	"You start mending the mechanisms under [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc/face/fix_screen/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] repairs [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You repair [target]'s screen with \the [tool].</span>" )
	target.op_stage.face = 3

/datum/surgery_step/ipc/face/fix_screen/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] on [target]'s screen, denting it up!</span>",
	"<span class='warning'>Your hand slips, smearing [tool] on [target]'s screen, denting it up!</span>")
	if(istype(tool, /obj/item/stack/nanopaste) || istype(tool, /obj/item/weapon/bonegel))
		BP.take_damage(0, 6, used_weapon = tool)

	else if(iswrenching(tool))
		BP.take_damage(12, 0, used_weapon = tool)
		BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc/face/close_shut
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/ipc/face/close_shut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face > 0

/datum/surgery_step/ipc/face/close_shut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to lock in place [target]'s screen with \the [tool].",
	"You are beginning to lock in place [target]'s screen with \the [tool].")
	..()

/datum/surgery_step/ipc/face/close_shut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] locks in place [target]'s screen with \the [tool].</span>",
	"<span class='notice'>You lock in place [target]'s screen \the [tool].</span>")
	BP.open = 0
	if (target.op_stage.face == 3)
		var/obj/item/organ/external/head/H = BP
		H.disfigured = FALSE
	target.op_stage.face = 0

/datum/surgery_step/ipc/face/close_shut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small dent on [target]'s screen with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, leaving a small dent on [target]'s screen with \the [tool]!</span>")
	BP.take_damage(6, 0, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//						Gender Reassignment						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/gender_reassignment
	priority = 1
	can_infect = 0
	blood_level = 1
	allowed_species = list("exclude", IPC, DIONA, PODMAN, VOX)

/datum/surgery_step/gender_reassignment/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!ishuman(target))
		return 0
	if (target_zone != BP_GROIN)
		return 0
	var/obj/item/organ/external/groin = target.get_bodypart(BP_GROIN)
	if (!groin)
		return 0
	if (groin.open < 1)
		return 0
	return 1

/datum/surgery_step/gender_reassignment/reshape_genitals
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/gender_reassignment/reshape_genitals/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(target.gender == FEMALE)
		user.visible_message("[user] begins to reshape [target]'s genitals to look more masculine with \the [tool].", \
		"You start to reshape [target]'s genitals to look more masculine with \the [tool]." )
	else
		user.visible_message("[user] begins to reshape [target]'s genitals to look more feminine with \the [tool].", \
		"You start to reshape [target]'s genitals to look more feminine with \the [tool]." )
	target.custom_pain("The pain in your groin is living hell!",1)
	..()

/datum/surgery_step/gender_reassignment/reshape_genitals/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(target.gender == FEMALE)
		user.visible_message("<span class='notice'>[user] has made a man of [target] with \the [tool].</span>" , \
		"<span class='notice'>You have made a man of [target].</span>")
		target.gender = MALE
	else
		user.visible_message("<span class='notice'>[user] has made a woman of [target] with \the [tool].</span>" , \
		"<span class='notice'>You have made a woman of [target].</span>")
		target.gender = FEMALE

	target.regenerate_icons()

/datum/surgery_step/gender_reassignment/reshape_genitals/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.bodyparts_by_name[BP_GROIN]
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s genitals with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing [target]'s genitals with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

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
	var/datum/reagents/R = target.reagents
	if(!R.has_reagent("metatrombine"))
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
/datum/surgery_step/ipc/generic
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipc/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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

/datum/surgery_step/ipc/generic/screw_open
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/ipc/generic/screw_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 0 && target_zone != O_MOUTH

/datum/surgery_step/ipc/generic/screw_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to unscrew [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You start to unscrew [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "%[BP.name]'S MAINTENANCE HATCH% UNATHORISED ACCESS ATTEMPT DETECTED!")
	..()

/datum/surgery_step/ipc/generic/screw_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has loosen bolts on [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You have unscrewed [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",)
	BP.open = 1
	BP.take_damage(1, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc/generic/screw_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scratching [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scratching [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/ipc/generic/pry_open
	allowed_tools = list(
	/obj/item/weapon/crowbar = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/circular_saw = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/ipc/generic/pry_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 1

/datum/surgery_step/ipc/generic/pry_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to pry open [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You start to pry open [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "%[BP.name]'s MAINTENANCE HATCH% DAMAGE DETECTED. CEASE APPLIED DAMAGE.")
	..()

/datum/surgery_step/ipc/generic/pry_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] pries open [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You pry open [target]'s [BP.name]'s maintenace hatch with \the [tool].</span>")
	BP.open = 2

/datum/surgery_step/ipc/generic/pry_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, damaging [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(12, 0, used_weapon = tool)

/datum/surgery_step/ipc/generic/close_shut
	allowed_tools = list(
	/obj/item/weapon/screwdriver = 100,
	/obj/item/weapon/scalpel = 75,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/ipc/generic/close_shut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open && target_zone != O_MOUTH

/datum/surgery_step/ipc/generic/close_shut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to lock [target]'s [BP.name]'s maintenance hatch with \the [tool].",
	"You are beginning to lock [target]'s [BP.name]'s maintenance hatch with \the [tool].")
	..()

/datum/surgery_step/ipc/generic/close_shut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] locks [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>",
	"<span class='notice'>You lock [target]'s [BP.name]'s maintenance hatch with \the [tool].</span>")
	BP.open = 0

/datum/surgery_step/ipc/generic/close_shut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, denting [target]'s [BP.name]'s maintenance hatch with \the [tool]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)

//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	allowed_species = null

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && !(BP.status & ORGAN_BLEEDING) && (target_zone != BP_CHEST || target.op_stage.ribcage == 2)

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return 1
		if (BP_CHEST)
			return 3
		if (BP_GROIN)
			return 2
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return "cranial"
		if (BP_CHEST)
			return "thoracic"
		if (BP_GROIN)
			return "abdominal"
	return ""

/datum/surgery_step/cavity/proc/remove_from_cavity(mob/user, mob/target, obj/obj_to_remove, obj/item/organ/external/BP, obj/tool)
	BP.embedded_objects -= obj_to_remove
	for(var/datum/wound/W in BP.wounds)
		if(obj_to_remove in W.embedded_objects)
			W.embedded_objects -= obj_to_remove
			break
	obj_to_remove.forceMove(get_turf(target))
	if(isitem(obj_to_remove))
		var/obj/item/I = obj_to_remove
		I.item_actions_special = initial(I.item_actions_special)
		I.remove_item_actions(target)
	user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [BP.name] with \the [tool].</span>", \
	"<span class='notice'>You take [obj_to_remove] out of incision on [target]'s [BP.name]s with \the [tool].</span>" )

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && !BP.cavity && !BP.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] makes some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>", \
	"<span class='notice'>You make some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>" )

/datum/surgery_step/cavity/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && BP.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(BP)] cavity wall with \the [tool].", \
	"You start mending [target]'s [get_cavity(BP)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] mends [target]'s [get_cavity(BP)] cavity walls with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s [get_cavity(BP)] cavity walls with \the [tool].</span>" )

/datum/surgery_step/cavity/close_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(0, 20, used_weapon = tool)

/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && !BP.hidden && BP.cavity && tool.w_class <= get_max_wclass(BP)

/datum/surgery_step/cavity/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(BP)] cavity.", \
	"You start putting \the [tool] inside [target]'s [get_cavity(BP)] cavity." )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)

	user.visible_message("<span class='notice'>[user] puts \the [tool] inside [target]'s [get_cavity(BP)] cavity.</span>", \
	"<span class='notice'>You put \the [tool] inside [target]'s [get_cavity(BP)] cavity.</span>" )
	if (tool.w_class > get_max_wclass(BP)/2 && prob(50) && BP.sever_artery())
		to_chat(user, "<span class='warning'>You tear some blood vessels trying to fit such a big object in this cavity.</span>")
		BP.owner.custom_pain("You feel something rip in your [BP.name]!", 1)
	if(istype(tool, /obj/item/gland))	//Abductor surgery integration
		if(target_zone != BP_CHEST)
			return
		else
			var/obj/item/gland/gland = tool
			user.drop_from_inventory(gland, target)
			gland.Inject(target)
			BP.cavity = 0
			return
	user.drop_from_inventory(tool, target)
	BP.hidden = tool
	BP.cavity = 0
	tool.item_actions_special = TRUE
	tool.add_item_actions(target)

/datum/surgery_step/cavity/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/cavity/implant_removal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		if(BP.stage == 3)
			return FALSE

		return BP && ((BP.open == 3 && BP.body_zone == BP_CHEST) || (BP.open == 2))

/datum/surgery_step/cavity/implant_removal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts poking around inside the incision on [target]'s [BP.name] with \the [tool].", \
	"You start poking around inside the incision on [target]'s [BP.name] with \the [tool]" )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	if(length(BP.embedded_objects))
		var/list/list_of_embed_types = list()
		var/list/embed_object_shrapnel = list()
		var/list/embed_object_implants = list()
		var/list/embed_object_else = list()
		for(var/embed_object in BP.embedded_objects)
			if(istype(embed_object, /obj/item/weapon/shard/shrapnel))
				embed_object_shrapnel += embed_object
				continue
			if(istype(embed_object, /obj/item/weapon/implant))
				embed_object_implants += embed_object
				continue
			embed_object_else += embed_object
		for(var/atom/embed_object as anything in embed_object_implants)
			embed_object_implants[embed_object] = image(icon = embed_object.icon, icon_state = embed_object.icon_state)
		for(var/atom/embed_object as anything in embed_object_else)
			embed_object_else[embed_object] = image(icon = embed_object.icon, icon_state = embed_object.icon_state)
		if(embed_object_shrapnel.len)
			list_of_embed_types += list("Shrapnel" = image(icon = 'icons/obj/shards.dmi', icon_state = "shrapnellarge"))
		if(embed_object_implants.len)
			list_of_embed_types += list("Implants" = embed_object_implants[pick(embed_object_implants)])
		if(embed_object_else.len)
			list_of_embed_types += list("Else" = embed_object_else[pick(embed_object_else)])
		var/list_to_choose = show_radial_menu(user, target, list_of_embed_types, radius = 30, require_near = TRUE, tooltips = TRUE)
		if(!list_to_choose)
			user.visible_message("<span class='notice'>[user] removes \the [tool] from [target]'s [BP.name].</span>", \
			"<span class='notice'>There's something inside [target]'s [BP.name], but you decided not to touch it.</span>" )
			return
		switch(list_to_choose)
			if("Shrapnel")
				var/atom/picked_obj = pick(embed_object_shrapnel)
				remove_from_cavity(user, target, picked_obj, BP, tool)
			if("Implants")
				var/choosen_object = show_radial_menu(user, target, embed_object_implants, radius = 50, require_near = TRUE, tooltips = TRUE)
				if(choosen_object)
					var/obj/item/weapon/implant/imp = choosen_object
					imp.eject()
					remove_from_cavity(user, target, choosen_object, BP, tool)
					target.sec_hud_set_implants()
			if("Else")
				var/choosen_object = show_radial_menu(user, target, embed_object_else, radius = 50, require_near = TRUE, tooltips = TRUE)
				if(choosen_object)
					if(istype(choosen_object, /mob/living/simple_animal/borer))
						var/mob/living/simple_animal/borer/worm = choosen_object
						if(worm.controlling)
							target.release_control()
						worm.detatch()
					remove_from_cavity(user, target, choosen_object, BP, tool)
		playsound(target, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)

	else if (BP.hidden)
		user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You take something out of incision on [target]'s [BP.name]s with \the [tool].</span>" )
		BP.hidden.forceMove(get_turf(target))
		BP.hidden.item_actions_special = initial(BP.hidden.item_actions_special)
		BP.hidden.remove_item_actions(target)
		if(!BP.hidden.blood_DNA)
			BP.hidden.blood_DNA = list()
		BP.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
		BP.hidden.update_icon()
		BP.hidden = null
	else
		user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [BP.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [BP.name].</span>" )

/datum/surgery_step/cavity/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
	if (length(BP.embedded_objects))
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		var/obj/item/weapon/implant/imp = locate(/obj/item/weapon/implant) in BP.embedded_objects
		if (prob(fail_prob))
			user.visible_message("<span class='warning'>Внутри [CASE(BP, GENITIVE_CASE)] [target] что-то пищит!</span>")
			playsound(imp, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
			addtimer(CALLBACK(imp, TYPE_PROC_REF(/obj/item/weapon/implant, use_implant)), 3 SECONDS)

//Procedures in this file: limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb
	can_infect = 0

/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP)
		return 0
	if(target_zone in list(O_EYES , O_MOUTH))
		return 0
	return target_zone != BP_CHEST


/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/cut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		return !target.op_stage.bodyparts[target_zone]

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].", \
	"You start cutting away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>",	\
	"<span class='notice'>You cut away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_CUT_AWAY

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [BP.name] open!</span>", \
		"<span class='warning'>Your hand slips, cutting [target]'s [BP.name] open!</span>")
		target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)


/datum/surgery_step/limb/mend
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		return target.op_stage.bodyparts[target_zone] && target.op_stage.bodyparts[target_zone] == ORGAN_CUT_AWAY

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to reposition flesh and nerve endings where where [target]'s [parse_zone(target_zone)] used to be with [tool].", \
	"You start repositioning flesh and nerve endings where [target]'s [parse_zone(target_zone)] used to be with [tool].")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [target]'s [parse_zone(target_zone)] used to be with [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and nerve endings where [target]'s [parse_zone(target_zone)] used to be with [tool].</span>")
	target.op_stage.bodyparts[target_zone] = 3

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing flesh on [target]'s [BP.name]!</span>", \
		"<span class='warning'>Your hand slips, tearing flesh on [target]'s [BP.name]!</span>")
		target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)


/datum/surgery_step/limb/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/limb/prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		return target.op_stage.bodyparts[target_zone] && target.op_stage.bodyparts[target_zone] == 3

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].", \
	"You start adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>",	\
	"<span class='notice'>You have finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_ATTACHABLE

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s [BP.name]!</span>", \
		"<span class='warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
		target.apply_damage(10, BURN, BP)


/datum/surgery_step/limb/attach
	allowed_tools = list(
	/obj/item/organ/external = 100,
	/obj/item/robot_parts = 100,
	)
	allowed_species = null

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(istype(tool, /obj/item/robot_parts))
			var/obj/item/robot_parts/p = tool
			if (target_zone != p.part)
				to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
				return FALSE
			if(!p.can_attach())
				to_chat(user, "<span class='userdanger'>You need to attach a flash to [p] first!</span>")
				return FALSE
			return target.op_stage.bodyparts[target_zone] == ORGAN_ATTACHABLE
		if(isbodypart(tool))
			var/obj/item/organ/external/p = tool
			if (target_zone != p.body_zone)
				to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
				return FALSE
			if(!p.is_compatible(target))
				to_chat(user, "<span class='userdanger'>This does not fit!</span>")
				return FALSE
			return target.op_stage.bodyparts[target_zone] == ORGAN_ATTACHABLE

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts attaching \the [tool] where [target]'s [parse_zone(target_zone)] used to be.",
	"You start attaching \the [tool] where [target]'s [parse_zone(target_zone)] used to be.")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP

	if(istype(tool, /obj/item/robot_parts))
		var/obj/item/robot_parts/L = tool
		if(!L.can_attach())
			return
		BP = new L.bodypart_type()
		target.remove_from_mob(tool)
	else if(isbodypart(tool))
		BP = tool

	if(!BP)
		return

	user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [parse_zone(target_zone)] used to be.</span>",
	"<span class='notice'>You have attached \the [tool] where [target]'s [parse_zone(target_zone)] used to be.</span>")

	user.remove_from_mob(tool)
	BP.insert_organ(target, surgically = TRUE)

	if(istype(tool, /obj/item/robot_parts))
		qdel(tool)
	target.update_body(BP.body_zone)
	target.updatehealth()
	target.UpdateDamageIcon(BP)
	target.op_stage.bodyparts -= target_zone

	if(istype(BP, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/B = BP
		if(istype(BP, /obj/item/organ/external/head/robot) && !target.has_organ(O_EYES))
			var/obj/item/organ/internal/eyes/ipc/cameras = new(null)
			cameras.insert_organ(target)
		if (B.brainmob && B.brainmob.mind)
			B.brainmob.mind.transfer_to(target)
			target.dna = B.brainmob.dna
			QDEL_NULL(B.brainmob)
		target.f_style = B.f_style
		target.h_style = B.h_style
		target.grad_style = B.grad_style
		target.r_facial = B.r_facial
		target.g_facial = B.g_facial
		target.b_facial = B.b_facial
		target.dyed_r_facial = B.dyed_r_facial
		target.dyed_g_facial = B.dyed_g_facial
		target.dyed_b_facial = B.dyed_b_facial
		target.facial_painted = B.facial_painted
		target.r_hair = B.r_hair
		target.g_hair = B.g_hair
		target.b_hair = B.b_hair
		target.dyed_r_hair = B.dyed_r_hair
		target.dyed_g_hair = B.dyed_g_hair
		target.dyed_b_hair = B.dyed_b_hair
		target.r_grad = B.r_grad
		target.g_grad = B.g_grad
		target.b_grad = B.b_grad
		target.hair_painted = B.hair_painted
		target.update_body(BP_HEAD, update_preferences = TRUE)
		target.timeofdeath = min(target.timeofdeath, world.time - DEFIB_TIME_LIMIT) // so they cannot be defibbed
		ADD_TRAIT(target, TRAIT_NO_CLONE, GENERIC_TRAIT) // so they cannot be cloned

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s [BP.name]!</span>",
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s [BP.name]!</span>")
	target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP)

//////////////////////////////////////////////////////////////////
//						ROBO LIMB SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc/limb
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipc/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP)
		return 0
	if(target_zone in list(O_EYES , O_MOUTH))
		return 0
	return target_zone != BP_CHEST


/datum/surgery_step/ipc/limb/cut_wires
	allowed_tools = list(
	/obj/item/weapon/wirecutters = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ipc/limb/cut_wires/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		return !target.op_stage.bodyparts[target_zone]

/datum/surgery_step/ipc/limb/cut_wires/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to reposition wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].",
	"You begin to reposition wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].")
	..()

/datum/surgery_step/ipc/limb/cut_wires/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finished repositioning wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>",
	"<span class='notice'>You finished repositioning wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_CUT_AWAY

/datum/surgery_step/ipc/limb/cut_wires/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [BP.name] open!</span>",
		"<span class='warning'>Your hand slips, cutting [target]'s [BP.name] open!</span>")
		target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)

/datum/surgery_step/ipc/limb/ipc_prepare
	allowed_tools = list(
	/obj/item/weapon/wrench = 100,
	/obj/item/weapon/bonesetter = 75
	)

	min_duration = 60
	max_duration = 70
	required_skills = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED, /datum/skill/engineering = SKILL_LEVEL_NOVICE)

/datum/surgery_step/ipc/limb/ipc_prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		return target.op_stage.bodyparts[target_zone] && target.op_stage.bodyparts[target_zone] == ORGAN_CUT_AWAY

/datum/surgery_step/ipc/limb/ipc_prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].",
	"You start adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].")
	..()

/datum/surgery_step/ipc/limb/ipc_prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>",
	"<span class='notice'>You have finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_ATTACHABLE

/datum/surgery_step/ipc/limb/ipc_prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s [BP.name]!</span>",
		"<span class='warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
		target.apply_damage(10, BRUTE, BP)

//////////////////////////////////////////////////////////////////
//						Lipoplasty								//
//////////////////////////////////////////////////////////////////
/datum/surgery_status
	var/lipoplasty = 0

/datum/surgery_step/lipoplasty
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/lipoplasty/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return target_zone == BP_CHEST

/datum/surgery_step/lipoplasty/cut_fat
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/lipoplasty/cut_fat/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open == 1 && target.op_stage.lipoplasty == 0

/datum/surgery_step/lipoplasty/cut_fat/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!target.has_quirk(/datum/quirk/fatness))
		user.visible_message("[user] begins to cut away [target]'s excess fat with \the [tool].",
			"You begin to cut away [target]'s excess fat with \the [tool].")
		if (target.overeatduration > 0)
			target.custom_pain("Something hurts horribly in your chest!", 1)
	else
		user.visible_message("[user] starts inspecting [target]'s body.",
			"You begin inspecting [target]'s body.")
	..()

/datum/surgery_step/lipoplasty/cut_fat/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!target.has_quirk(/datum/quirk/fatness))
		if (target.overeatduration > 0)
			user.visible_message("<span class='notice'>[user] cuts [target]'s excess fat loose with \the [tool].</span>",
				"<span class='notice'>You have cut [target]'s excess fat loose with \the [tool].</span>")
			target.op_stage.lipoplasty = 1
		else
			user.visible_message("<span class='notice'>Unfortunately, there is nothing to cut on [target] with \the [tool].</span>",
				"<span class='notice'>Unfortunately, there is nothing to cut on [target] with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] realizes, that there is no known solution to resolve [target]'s fatness problem.</span>",
			"<span class='notice'>Unfortunately, there is nothing you can do with the [target]'s excess fat.</span>")

/datum/surgery_step/lipoplasty/cut_fat/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='red'>[user]'s hand slips, cutting [target]'s chest with \the [tool]!</span>",
		"<span class='red'>Your hand slips, cutting [target]'s chest with \the [tool]!</span>")
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/lipoplasty/remove_fat
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 50
	max_duration = 85

/datum/surgery_step/lipoplasty/remove_fat/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open == 1 &&  target.op_stage.lipoplasty == 1

/datum/surgery_step/lipoplasty/remove_fat/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to extract [target]'s loose fat with \the [tool].", \
	"You begin to extract [target]'s loose fat with \the [tool].")
	if (target.overeatduration > 0)
		target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/lipoplasty/remove_fat/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	target.op_stage.lipoplasty = 0
	if (target.overeatduration > 0)
		user.visible_message("<span class='notice'>[user] extracts [target]'s fat with \the [tool].</span>",		\
		"<span class='notice'>You have removed [target]'s fat loose with \the [tool].</span>")
		var/removednutriment = max(75, (target.nutrition + target.overeatduration) - 450)
		target.nutrition = 450
		target.overeatduration = 0
		var/obj/item/weapon/reagent_containers/food/snacks/meat/P = new
		P.name = "fatty meat"
		P.desc = "Extremely fatty tissue taken from a patient."
		P.reagents.add_reagent ("nutriment", (removednutriment / 15))
		var/amount = 0
		if (target.reagents.total_volume > 0)
			amount = target.reagents.total_volume
			target.reagents.remove_reagent("nutriment",amount)
		var/obj/item/meatslab = P
		meatslab.loc = get_turf(target)
		playsound(target, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
	else
		user.visible_message("<span class='notice'>Unfortunately, there is nothing to extract of [target]'s with \the [tool].</span>",		\
		"<span class='notice'>Unfortunately, there is nothing to extract of [target] with \the [tool].</span>")

/datum/surgery_step/lipoplasty/remove_fat/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s belly with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cutting [target]'s belly with \the [tool]!</span>" )
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)

//Procedures in this file: Inernal wound patching, Implant removal, Fixing groin organs in IPCs and Dioneae
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && (BP.status & ORGAN_ARTERY_CUT) && BP.open >= 2

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [BP.name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("The pain in [BP.name] is unbearable!",1)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has patched the damaged vein in [target]'s [BP.name] with \the [tool].</span>", \
		"<span class='notice'>You have patched the damaged vein in [target]'s [BP.name] with \the [tool].</span>")

	BP.status &= ~ORGAN_ARTERY_CUT
	if (ishuman(user) && prob(40))
		var/mob/living/carbon/human/H = user
		H.bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//					GROIN ORGAN PATCHING						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/groin_organs
	priority = 3
	can_infect = 0
	blood_level = 1
	allowed_species = null // Allows surgery for all species, whereas previously it was only allowed for DIONA, IPC, VOX, and PODMAN

/datum/surgery_step/groin_organs/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(target_zone != BP_GROIN)
		return FALSE
	var/obj/item/organ/external/groin = target.get_bodypart(BP_GROIN)
	if(!groin)
		return FALSE
	if(groin.open < 1)
		return FALSE
	for(var/obj/item/organ/internal/IO in groin.bodypart_organs) // If they ain't got nothing to fix, don't.
		return TRUE
	return FALSE

/datum/surgery_step/groin_organs/fixing
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,
	/obj/item/stack/medical/bruise_pack = 20,
	/obj/item/stack/medical/bruise_pack/tajaran = 70
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/groin_organs/fixing/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	var/list/dead_organs = list()
	var/has_treatable = FALSE
	for(var/obj/item/organ/internal/IO as anything in BP.bodypart_organs)
		if(IO.damage > 0)
			if(IO.status & ORGAN_DEAD)
				dead_organs += IO
			else
				has_treatable = TRUE
	if(has_treatable)
		return TRUE
	necrotic_organs_warning(user, target, dead_organs)
	return FALSE

/datum/surgery_step/groin_organs/fixing/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	var/list/dead_organs = list()
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.status & ORGAN_DEAD)
			dead_organs += IO
			continue
		if(IO && IO.damage > 0)
			if(!IO.is_robotic())
				user.visible_message("[user] starts treating damage to [target]'s [IO.name] with [tool_name].",
				"You start treating damage to [target]'s [IO.name] with [tool_name]." )
			else
				user.visible_message("<span class='notice'>[user] attempts to repair [target]'s mechanical [IO.name] with [tool_name]...</span>",
				"<span class='notice'>You attempt to repair [target]'s mechanical [IO.name] with [tool_name]...</span>")
	necrotic_organs_warning(user, target, dead_organs)

	if(HAS_TRAIT(target, TRAIT_NO_PAIN))
		to_chat(target, "You notice slight movement in your groin.")
	else
		target.custom_pain("The pain in your groin is living hell!",1)
	..()

/datum/surgery_step/groin_organs/fixing/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.status & ORGAN_DEAD)
				continue
			if(!IO.is_robotic())
				user.visible_message("<span class='notice'>[user] treats damage to [target]'s [IO.name] with [tool_name].</span>",
				"<span class='notice'>You treat damage to [target]'s [IO.name] with [tool_name].</span>" )
				IO.damage = 0
			else
				user.visible_message("<span class='notice'>[user] pokes [target]'s mechanical [IO.name] with [tool_name]...</span>",
				"<span class='notice'>You poke [target]'s mechanical [IO.name] with [tool_name]...</span> <span class='warning'>For no effect, since it's robotic.</span>")

/datum/surgery_step/groin_organs/fixing/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s groin with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s groin with \the [tool]!</span>")
	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		if(istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			target.adjustToxLoss(7)
		else
			dam_amt = 5
			target.adjustToxLoss(10)
			BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)

	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			IO.take_damage(dam_amt,0)

/datum/surgery_step/groin_organs/fixing_robot //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/weapon/bonegel = 30,
	/obj/item/weapon/wrench = 70
	)

	allowed_species = null // Allows the surgery on prosthetic organs for all species, whereas previously it was only allowed for IPC

	min_duration = 70
	max_duration = 90
	required_skills = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED, /datum/skill/engineering = SKILL_LEVEL_NOVICE)

/datum/surgery_step/groin_organs/fixing_robot/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/is_groin_organ_damaged = FALSE
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			is_groin_organ_damaged = TRUE
			break
	return is_groin_organ_damaged

/datum/surgery_step/groin_organs/fixing_robot/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			user.visible_message("[user] starts mending the mechanisms on [target]'s [IO] with \the [tool].",
			"You start mending the mechanisms on [target]'s [IO] with \the [tool]." )
			continue
	if(HAS_TRAIT(target, TRAIT_NO_PAIN))
		to_chat(target, "You notice slight movement in your groin.")
	else
		target.custom_pain("The pain in your groin is living hell!",1)
	..()

/datum/surgery_step/groin_organs/fixing_robot/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			user.visible_message("<span class='notice'>[user] repairs [target]'s [IO] with \the [tool].</span>",
			"<span class='notice'>You repair [target]'s [IO] with \the [tool].</span>" )
			IO.damage = 0

/datum/surgery_step/groin_organs/fixing_robot/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/groin/BP = target.get_bodypart(BP_GROIN)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name], gumming it up!</span>",
		"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name], gumming it up!</span>")
	if(istype(tool, /obj/item/stack/nanopaste) || istype(tool, /obj/item/weapon/bonegel))
		BP.take_damage(0, 6, used_weapon = tool)

	else if(iswrenching(tool))
		BP.take_damage(12, 0, used_weapon = tool)
		BP.take_damage(5, 0, DAM_SHARP|DAM_EDGE, tool)

	var/dam_amt = 2
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			IO.take_damage(dam_amt,0)
//////////////////////////////////////////////////////////////////
//						Plastic Surgery							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/plastic_surgery
	clothless = 0
	priority = 3
	can_infect = 0

/datum/surgery_step/plastic_surgery/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	return target_zone == O_MOUTH

/datum/surgery_step/plastic_surgery/retract_face
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75, \
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/plastic_surgery/retract_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.plasticsur == 0 && target.op_stage.face == 1

/datum/surgery_step/plastic_surgery/retract_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting the skin on [target]'s face with \the [tool].", \
	"You start adjusting the skin on [target]'s face with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/retract_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pulls the skin on [target]'s face with \the [tool].</span>",	\
	"<span class='notice'>You pull the skin on [target]'s face with \the [tool].</span>")
	target.op_stage.plasticsur = 1

/datum/surgery_step/plastic_surgery/retract_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/plastic_surgery/adjust_vocal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 10
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/plastic_surgery/adjust_vocal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.plasticsur == 1 && target.op_stage.face == 1

/datum/surgery_step/plastic_surgery/adjust_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	var/obj/item/organ/external/head/H = BP
	if (H.disfigured == 1)
		user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
		"You start mending [target]'s vocal cords with \the [tool].")
	else
		user.visible_message("[user] starts adjusting [target]'s vocal cords with \the [tool].", \
		"You start adjusting [target]'s vocal cords with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/adjust_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	var/obj/item/organ/external/head/H = BP
	if (H.disfigured == 1)
		user.visible_message("<span class='notice'>[user] mends [target]'s vocal cords with \the [tool].</span>", \
		"<span class='notice'>You mend [target]'s vocal cords with \the [tool].</span>")
		H.disfigured = 0
	else
		user.visible_message("<span class='notice'>[user] adjusts [target]'s vocal cords with \the [tool].</span>", \
		"<span class='notice'>You adjust [target]'s vocal cords with \the [tool].</span>")
	target.op_stage.plasticsur = 2

/datum/surgery_step/plastic_surgery/adjust_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
	target.losebreath += 10

//reshape_face
/datum/surgery_step/plastic_surgery/reshape_face
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/plastic_surgery/reshape_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.plasticsur == 2 && target.op_stage.face == 1

/datum/surgery_step/plastic_surgery/reshape_face/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	target.op_stage.plastic_new_name = sanitize_name(input(user, "Choose your character's name:", "Changing")  as text|null)
	return target.op_stage.plastic_new_name && checks_for_surgery(target, user, clothless)

/datum/surgery_step/plastic_surgery/reshape_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to alter [target]'s appearance with \the [tool].", \
	"You begin to alter [target]'s appearance with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/reshape_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] alters [target]'s appearance with \the [tool].</span>",		\
	"<span class='notice'>You alter [target]'s appearance with \the [tool].</span>")
	if(target.op_stage.plastic_new_name)
		target.real_name = target.op_stage.plastic_new_name
		target.op_stage.plastic_new_name = null

/datum/surgery_step/plastic_surgery/reshape_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/plastic_surgery/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/plastic_surgery/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face > 0 && target.op_stage.plasticsur > 0

/datum/surgery_step/plastic_surgery/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s face and neck with \the [tool].</span>", \
	"<span class='notice'>You cauterize theon [target]'s face and neck with \the [tool].</span>")
	BP.open = 0
	BP.status &= ~ORGAN_BLEEDING
	if (target.op_stage.plasticsur == 2)
		var/obj/item/organ/external/head/H = BP
		H.disfigured = 0
	target.op_stage.plasticsur = 0
	target.op_stage.face = 0

/datum/surgery_step/plastic_surgery/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>")
	BP.take_damage(0, 4, used_weapon = tool)

/* SURGERY STEPS */
/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	//type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = list("exclude", IPC)

	//duration of the step
	var/min_duration = 0
	var/max_duration = 0

	//evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

	//Cloth check
	var/clothless = 1
	var/required_skills = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED)
	var/skills_speed_bonus = -0.30 // -30% for each surplus level

// returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	for(var/T in allowed_tools)
		if(istype(tool, T))
			return allowed_tools[T]
	return FALSE

// Checks if this step applies to the mutantrace of the user.
/datum/surgery_step/proc/is_valid_mutantrace(mob/living/carbon/human/target)
	if(ishuman(target) && allowed_species)
		if(("exclude" in allowed_species) == (target.get_species() in allowed_species))
			return FALSE
	return TRUE

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return FALSE

/datum/surgery_step/proc/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return TRUE

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(can_infect && BP)
		spread_germs_to_organ(BP, user, tool)
	if(ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level)
			H.bloody_hands(target, 0)
		if(blood_level > 1)
			H.bloody_body(target, 0)
	return

// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return null

/// Outputs a consolidated warning about necrotic organs that can't be treated by "fix" step.
/datum/surgery_step/proc/necrotic_organs_warning(mob/living/user, mob/living/carbon/human/target, list/dead_organs)
	if(!length(dead_organs))
		return
	var/list/organ_names = list()
	for(var/obj/item/organ/internal/IO as anything in dead_organs)
		organ_names += IO.name
	if(organ_names.len == 1)
		to_chat(user, "<span class='warning'>[target]'s [organ_names[1]] is necrotic and can't be treated this way.</span>")
	else
		to_chat(user, "<span class='warning'>[target]'s [get_english_list(organ_names)] are necrotic and can't be treated this way.</span>")

/proc/spread_germs_to_organ(obj/item/organ/external/BP, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(BP))
		return

	var/germ_level = 0
	if(user.gloves)
		germ_level += user.gloves.germ_level
	else
		germ_level += user.germ_level

	if(tool.blood_DNA && tool.blood_DNA.len) //germs from blood-stained tools
		germ_level += GERM_LEVEL_AMBIENT * 0.25

	if(HAS_TRAIT(tool, TRAIT_XENO_FUR))
		germ_level += GERM_LEVEL_AMBIENT * 0.25

	if(ishuman(user) && !user.is_skip_breathe() && !user.wear_mask) //wearing a mask helps preventing people from breathing germs into open incisions
		germ_level += user.germ_level * 0.25

	BP.germ_level = max(germ_level, BP.germ_level)
	if(BP.germ_level)
		BP.owner.bad_bodyparts |= BP

/proc/checks_for_surgery(mob/living/carbon/M, mob/living/user, check_covering = TRUE)
	if(!user.Adjacent(M))
		return FALSE
	if(!can_operate(M, user))
		return FALSE
	if(!istype(M))
		return FALSE
	if(user.a_intent == INTENT_HARM)	//check for Hippocratic Oath
		return FALSE
	if(user.is_busy(null)) // No target so we allow multiple players to do surgeries on one pawn.
		return FALSE
	if(ishuman(M) && check_covering)
		return check_human_covering(M, user)
	return TRUE

/proc/get_human_covering(mob/living/carbon/human/T)
	var/covered
	for(var/obj/item/I in list(T.wear_suit, T.w_uniform, T.gloves, T.glasses, T.head, T.wear_mask, T.shoes))
		if(I && I.body_parts_covered)
			covered |= I.body_parts_covered
	return covered

/proc/check_covered_bodypart(mob/living/carbon/human/T, covered)
	for(var/obj/item/I in list(T.wear_suit, T.w_uniform, T.gloves, T.glasses, T.head, T.wear_mask, T.shoes))
		if(I && I.body_parts_covered & covered)
			return TRUE
	return FALSE

/proc/get_clothing_by_covered_bodypart(mob/living/carbon/human/T, covered)
	var/static/list/zone_by_clothing_part = list(
		BP_CHEST = UPPER_TORSO,
		BP_GROIN = LOWER_TORSO,
		BP_L_LEG = LEG_LEFT,
		BP_R_LEG = LEG_RIGHT,
		BP_L_ARM = ARM_LEFT,
		BP_R_ARM = ARM_RIGHT,
		BP_HEAD = HEAD,
	)
	var/zone = zone_by_clothing_part[covered]
	for(var/obj/item/clothing/I in list(T.wear_suit, T.w_uniform, T.gloves, T.glasses, T.head, T.wear_mask, T.shoes))
		if(I && (I.body_parts_covered & zone))
			return I
	return FALSE

/proc/check_human_covering(mob/living/carbon/human/T, mob/living/user, covered)
	var/static/list/zone_by_clothing_part = list(
		BP_CHEST = UPPER_TORSO,
		BP_GROIN = LOWER_TORSO,
		BP_L_LEG = LEG_LEFT,
		BP_R_LEG = LEG_RIGHT,
		BP_L_ARM = ARM_LEFT,
		BP_R_ARM = ARM_RIGHT,
		BP_HEAD = HEAD,
		O_MOUTH = FACE,
		O_EYES = EYES,
	)

	var/zone = zone_by_clothing_part[user.get_targetzone()]
	if(!zone)
		return TRUE

	return !check_covered_bodypart(T, zone)

/proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool)
	checks_for_surgery(M, user, FALSE)
	var/target_zone = user.get_targetzone()
	var/covered
	if(ishuman(M))
		covered = get_human_covering(M)

	var/skillcheck = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[IS_SYNTHETIC])
			skillcheck = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

	if(!handle_fumbling(user, M, SKILL_TASK_AVERAGE, skillcheck, "<span class='notice'>You fumble around figuring out how to operate [M].</span>"))
		return

	for(var/datum/surgery_step/S in surgery_steps)
		//check, if target undressed for clothless operations
		if(S.clothless && ishuman(M) && !check_human_covering(M, user, covered))
			return FALSE

		//check if tool is right or close enough and if this step is possible
		if(S.tool_quality(tool) && S.can_use(user, M, target_zone, tool) && S.is_valid_mutantrace(M))
			if(!S.prepare_step(user, M, target_zone, tool))	//for some kind of checks
				return TRUE

			S.begin_step(user, M, target_zone, tool)		//...start on it
			var/step_duration = rand(S.min_duration, S.max_duration)

			//We had proper tools! (or RNG smiled.) and User did not move or change hands.
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!HAS_TRAIT(H, TRAIT_NO_PAIN) && !HAS_TRAIT(H, TRAIT_IMMOBILIZED))
					H.adjustHalLoss(25)
				if(prob(H.traumatic_shock) && !H.incapacitated(NONE))
					to_chat(user, "<span class='warning'>The patient is writhing in pain, this interferes with the operation!</span>")
					S.fail_step(user, H, target_zone, tool) //patient movements due to pain interfere with surgery
			if(user.mood_prob(S.tool_quality(tool)) && tool.use_tool(M,user, step_duration, volume=100, required_skills_override = S.required_skills, skills_speed_bonus = S.skills_speed_bonus, particle_type = /particles/tool/surgery) && user.get_targetzone() && target_zone == user.get_targetzone())
				S.end_step(user, M, target_zone, tool)		//finish successfully
			else if(tool.loc == user && user.Adjacent(M))		//or (also check for tool in hands and being near the target)
				S.fail_step(user, M, target_zone, tool)		//malpractice~
			else	// this failing silently was a pain.
				to_chat(user, "<span class='warning'>You must remain close to your patient to conduct surgery.</span>")

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.update_surgery()										//shows surgery results
			return	TRUE	  												//don't want to do weapony things after surgery
	return FALSE

/proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1

/datum/surgery_status
	var/plastic_new_name = null
	var/plasticsur = 0
	var/eyes = 0
	var/face = 0
	var/appendix = 0
	var/ribcage = 0
	var/skull = 0
	var/brain_cut = 0
	var/brain_fix = 0
	var/list/bodyparts = list() // Holds info about removed bodyparts

/datum/surgery_step/ipc
	can_infect = FALSE
	allowed_species = list(IPC)
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED, /datum/skill/surgery = SKILL_LEVEL_NOVICE)
	skills_speed_bonus = -0.2

//Procedures in this file: Damage repair surgery
//////////////////////////////////////////////////////////////////
//						TISSUE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/add_tissue
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack = 100,
	/obj/item/stack/medical/advanced/ointment = 100
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60


/datum/surgery_step/add_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	if(!ishuman(target))
		return FALSE

	if(tool.amount == 0)
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(!(BP.brute_dam > 20 || BP.burn_dam > 20))
		return FALSE

	return BP && BP.open >= 2 && BP.stage == 0

/datum/surgery_step/add_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.stage == 0)
		user.visible_message("<span class='notice'>[user] starts adding regenerative membrane to [target]'s [BP.name].</span>", \
		"<span class='notice'>You start adding regenerative membrane to [target]'s [BP.name].</span>")
	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/add_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		BP.trauma_kit = TRUE
	else if(istype(tool, /obj/item/stack/medical/advanced/ointment))
		BP.burn_kit = TRUE
	user.visible_message("<span class='notice'>[user] finishes  adding regenerative membrane to [target]'s [BP.name].</span>", \
		"<span class='notice'>You finish adding regenerative membrane to [target]'s [BP.name].</span>")
	tool.use(1)
	tool.update_icon()
	BP.stage = 3

/datum/surgery_step/add_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>")
	tool.use(1)
	tool.update_icon()

/datum/surgery_step/set_tissue
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,
	/obj/item/weapon/wirecutters = 75,
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/set_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	return BP && BP.open >= 2 && BP.stage == 3

/datum/surgery_step/set_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.stage == 3)
		user.visible_message("<span class='notice'>[user] starts connecting regenerative membrane with damaged tissue inside of [target]'s [BP.name].</span>", \
			"<span class='notice'>You start connecting regenerative membrane with damaged tissue inside of [target]'s [BP.name].</span>")
	target.custom_pain("The pain in your [BP.name] is going to make you pass out!",1)
	..()

/datum/surgery_step/set_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] finishes connecting regenerative membrane with damaged tissue inside of [target]'s [BP.name].</span>", \
		"<span class='notice'>[user] finish connecting regenerative membrane with damaged tissue inside of [target]'s [BP.name].</span>")
	if(BP.trauma_kit)
		BP.trauma_kit = FALSE
		BP.heal_damage(20)
		BP.disinfect()
		BP.status &= ~ORGAN_BLEEDING
	if(BP.burn_kit)
		BP.burn_kit = FALSE
		BP.heal_damage(0, 20)
		BP.salve()
	BP.stage = 0

/datum/surgery_step/set_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>")
	BP.burn_kit = FALSE
	BP.trauma_kit = FALSE
	BP.take_damage(5, 0, used_weapon = tool)
	BP.stage = 0
