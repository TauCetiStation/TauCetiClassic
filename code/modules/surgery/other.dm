/datum/surgery_step/brain/insert_brain
	allowed_tools = list(
	/obj/item/organ/internal/brain = 100
	)
	allowed_species = list("exclude", IPC, DIONA)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/brain/insert_brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(target_zone != BP_HEAD)
		return FALSE

	var/obj/item/organ/internal/I = tool
	if(!(target.get_species() in I.compability))
		user.visible_message ( "<span class='warning'> \The [I] not compability to [target]</span>")
		return FALSE

	if(I.requires_robotic_bodypart)
		user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.open >= BP_INTERNALS_OS && !target.has_brain())
		return TRUE
	return FALSE

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
//					GROIN ORGAN PATCHING						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/groin_organs
	priority = 3

	allowed_species = null // Allows surgery for all species, whereas previously it was only allowed for DIONA, IPC, VOX, and PODMAN

/datum/surgery_step/groin_organs/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(target_zone != BP_GROIN)
		return FALSE
	var/obj/item/organ/external/groin = target.get_bodypart(BP_GROIN)
	if(!groin)
		return FALSE
	if(groin.open < BP_SCALPEL_OS)
		return FALSE
	for(var/obj/item/organ/internal/IO in groin.bodypart_organs) // If they ain't got nothing to fix, don't.
		return TRUE
	return FALSE

/datum/surgery_step/groin_organs/fixing
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,
	/obj/item/stack/medical/bruise_pack/tajaran = 70,
	/obj/item/stack/medical/bruise_pack = 20
	)

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

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
	allowed_qualities = list(
	QUALITY_MENDING_IPC
	)

	allowed_species = null // Allows the surgery on prosthetic organs for all species, whereas previously it was only allowed for IPC

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS
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
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage/fix_chest_internal
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,
	/obj/item/stack/medical/bruise_pack/tajaran = 70,
	/obj/item/stack/medical/bruise_pack = 20
	)

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/ribcage/fix_chest_internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	if(BP.open != BP_RIBCAGE_OS)
		return FALSE
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

/datum/surgery_step/ribcage/fix_chest_internal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	var/list/dead_organs = list()
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.status & ORGAN_DEAD)
				dead_organs += IO
				continue
			if(!IO.is_robotic())
				user.visible_message("[user] starts treating damage to [target]'s [IO.name] with [tool_name].", \
				"You start treating damage to [target]'s [IO.name] with [tool_name]." )
			else
				user.visible_message("<span class='notice'>[user] attempts to repair [target]'s mechanical [IO.name] with [tool_name]...</span>", \
				"<span class='notice'>You attempt to repair [target]'s mechanical [IO.name] with [tool_name]...</span>")
	necrotic_organs_warning(user, target, dead_organs)

	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/ribcage/fix_chest_internal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO && IO.damage > 0)
			if(IO.status & ORGAN_DEAD)
				continue
			if(!IO.is_robotic())
				user.visible_message("[user] treats damage to [target]'s [IO.name] with [tool_name].", \
				"<span class='notice'>You treat damage to [target]'s [IO.name] with [tool_name].</span>" )
				IO.damage = 0
			else
				user.visible_message("<span class='notice'>[user] pokes [target]'s mechanical [IO.name] with [tool_name]...</span>", \
				"<span class='notice'>You poke [target]'s mechanical [IO.name] with [tool_name]... <span class='warning'>For no effect, since it's robotic.</span></span>")

/datum/surgery_step/ribcage/fix_chest_internal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s chest with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s chest with \the [tool]!</span>")
	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
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

/datum/surgery_step/ribcage/fix_chest_internal_robot //For artificial organs
	allowed_qualities = list(
	QUALITY_MENDING_IPC
	)
	allowed_species = null

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/ribcage/fix_chest_internal_robot/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	if(BP.open != BP_RETRACT_OS)
		return FALSE
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			return TRUE
	return FALSE

/datum/surgery_step/ribcage/fix_chest_internal_robot/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			user.visible_message("[user] starts mending the mechanisms on [target]'s [IO] with \the [tool].",
			"You start mending the mechanisms on [target]'s [IO] with \the [tool]." )
			continue
	if(HAS_TRAIT(target, TRAIT_NO_PAIN))
		target.custom_pain("You notice slight movement in your chest.",1)
	else
		target.custom_pain("The pain in your chest is a living hell!",1)
	..()

/datum/surgery_step/ribcage/fix_chest_internal_robot/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0 && IO.is_robotic())
			user.visible_message("<span class='notice'>[user] repairs [target]'s [IO] with \the [tool].</span>",
			"<span class='notice'>You repair [target]'s [IO] with \the [tool].</span>" )
			IO.damage = 0

/datum/surgery_step/ribcage/fix_chest_internal_robot/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
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

/datum/surgery_step/ipc/ribcage/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/chest/BP = target.get_bodypart(BP_CHEST)
	if(BP.open == BP_RIBCAGE_OS)
		return TRUE

	return FALSE

//////////////////////////////////////////////////////////////////
//				EXTRACTING IPC'S BRAIN							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc/ribcage/import_posibrain
	allowed_tools = list(
	/obj/item/device/mmi/posibrain = 100
	)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/ipc/ribcage/import_posibrain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts fiddling in \the [tool] into [target].",
	"Your start fiddling in \the [tool] into [target].")
	..()

/datum/surgery_step/ipc/ribcage/import_posibrain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] fiddled in \the [tool] into [target].</span>",
	"<span class='notice'>You fiddled in \the [tool] into [target].</span>")

	var/obj/item/device/mmi/posibrain/PB = tool
	if(PB.brainmob && PB.brainmob.mind)
		PB.brainmob.mind.transfer_to(target)
		target.dna = PB.brainmob.dna
	qdel(tool)
	target.stat = CONSCIOUS

	var/obj/item/organ/internal/heart/IO = target.organs_by_name[O_HEART]
	IO.heart_normalize()
	target.SetStunned(0)
	target.SetWeakened(0)
	target.SetParalysis(0)
	target.timeofdeath = 0

/datum/surgery_step/ipc/ribcage/take_accumulator
	allowed_qualities = list(
	QUALITY_SCREWING
	)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/ipc/ribcage/take_accumulator/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER] // IPC's liver, as of now is an accumulator.
	if(!locate(/obj/item/weapon/stock_parts/cell) in accum)
		return FALSE
	if(..())
		return TRUE
	return FALSE

/datum/surgery_step/ipc/ribcage/take_accumulator/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to unscrew [target]'s accumulator out with \the [tool].",
	"You start unscrewing [target]'s accumulator with \the [tool].")
	..()

/datum/surgery_step/ipc/ribcage/take_accumulator/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] unscrewed [target]'s accumulator with \the [tool].</span>",
	"<span class='notice'>You unscrewed [target]'s accumulator with \the [tool].</span>")
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER]
	var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in accum
	C.forceMove(get_turf(target))
	target.nutrition = 0
	if(!target.is_bruised_organ(O_KIDNEYS))
		to_chat(target, "<span class='warning italics'>%SHUTTING DOWN%</span>")

/datum/surgery_step/ipc/ribcage/put_accumulator
	allowed_tools = list(
	/obj/item/weapon/stock_parts/cell = 100
	)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/ipc/ribcage/put_accumulator/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER] // IPC's liver, as of now is an accumulator.
	if(locate(/obj/item/weapon/stock_parts/cell) in accum)
		return FALSE
	if(..())
		return TRUE
	return FALSE

/datum/surgery_step/ipc/ribcage/put_accumulator/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts putting in \the [tool] into [target]'s accumulator slot.",
	"You start putting in \the [tool] into [target]'s accumulator slot.")
	..()

/datum/surgery_step/ipc/ribcage/put_accumulator/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has put in \the [tool] into [target]'s accumulator slot.</span>",
	"<span class='notice'>You have put in \the [tool] into [target]'s accumulator slot.</span>")

	var/obj/item/organ/internal/accum = target.organs_by_name[O_LIVER]
	user.drop_from_inventory(tool, accum)

	var/obj/item/weapon/stock_parts/cell/C = tool

	target.nutrition = C.charge

/datum/surgery_step/ipc/ribcage/hearing_restoration
	allowed_tools = list(
		/obj/item/robot_parts/robot_component/radio = 100,
	)
	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/ipc/ribcage/hearing_restoration/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts putting in \the [tool] into [target]'s hearing module slot.",
	"You start putting in \the [tool] into [target]'s hearing module slot.")
	..()

/datum/surgery_step/ipc/ribcage/hearing_restoration/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has put in \the [tool] into [target]'s hearing module slot.</span>",
	"<span class='notice'>You have put in \the [tool] into [target]'s hearing module slot.</span>")

	qdel(tool)
	target.ear_damage = 0
	target.ear_deaf = 0
	target.sdisabilities &= ~DEAF


//Procedures in this file: Damage repair surgery
//////////////////////////////////////////////////////////////////
//						TISSUE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/add_tissue
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack = 100,
	/obj/item/stack/medical/advanced/ointment = 100
	)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS


/datum/surgery_step/add_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	if(!..())
		return FALSE

	if(tool.amount == 0)
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!(BP.brute_dam > 20 || BP.burn_dam > 20))
		return FALSE

	if(BP.open >= BP_RETRACT_OS && BP.trauma_kit == FALSE && BP.burn_kit == FALSE)
		return TRUE

	return FALSE

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

/datum/surgery_step/add_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/stack/medical/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and wasting regenerative membrane inside of [target]'s [BP.name]!</span>")
	tool.use(1)
	tool.update_icon()

//////////////////////////////////////////////////////////////////
//					 ORGANS SURGERY	          					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/organ_manipulation
	priority = 2
	allowed_species = list("exclude", IPC, DIONA, PODMAN)
	var/obj/item/organ/internal/I = null

/datum/surgery_step/organ_manipulation/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(target_zone in list(O_EYES , O_MOUTH, BP_HEAD))
		return FALSE
	if(BP.open >= BP_RETRACT_OS)
		return TRUE

	return FALSE

/datum/surgery_step/organ_manipulation/place
	priority = 0
	allowed_tools = list(
		/obj/item/organ/internal = 100
		)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/organ_manipulation/place/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	if(target_zone in list(O_EYES , O_MOUTH, BP_HEAD))
		return FALSE

	var/obj/item/organ/internal/I = tool
	if(I.requires_robotic_bodypart)
		user.visible_message ("<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
		return FALSE

	if(target_zone != I.parent_bodypart)
		user.visible_message ("<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return FALSE

	if(I.damage > (I.max_damage * 0.75))
		user.visible_message ("<span class='notice'> \The [I] is in no state to be transplanted.</span>")
		return FALSE

	if(target.get_int_organ(I))
		user.visible_message ("<span class='warning'> \The [target] already has [I].</span>")
		return FALSE

	if(!(target.get_species() in I.compability))
		user.visible_message ("<span class='warning'> \The [I] not compability to [target]</span>")
		return FALSE

	return TRUE

/datum/surgery_step/organ_manipulation/place/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
		"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")
	..()

/datum/surgery_step/organ_manipulation/place/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	I = tool
	if(target.get_int_organ(I))
		user.visible_message ( "<span class='warning'> \The [target] already has [I].</span>")
		return FALSE
	user.drop_from_inventory(tool)
	I.insert_organ(target)
	user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target].</span>", \
	"<span class='notice'> You have transplanted \the [tool] into [target].</span>")
	I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/organ_manipulation/place/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/organ_manipulation/treat_necrosis
	priority = 0

	allowed_qualities = list(
		QUALITY_DROP_LIQUID
	)

	min_duration = 12 SECONDS
	max_duration = 16 SECONDS

/datum/surgery_step/organ_manipulation/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/weapon/reagent_containers/C = tool
	if(!C.reagents.has_reagent("peridaxon"))
		msg = "[user] looks at \the [tool] and ponders."
		self_msg = "You are not sure if \the [tool] contains the peridaxon necessary to treat the necrosis."
		user.visible_message(msg, self_msg)
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!length(BP.bodypart_organs))
		return FALSE
	if(BP.open >= BP_RETRACT_OS)
		return TRUE

	return FALSE

/datum/surgery_step/organ_manipulation/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if (BP.bodypart_organs.len)
		var/list/embed_organs = list()
		for(var/embed_organ in BP.bodypart_organs)
			var/obj/item/organ/internal/IO = embed_organ
			if(IO.status & ORGAN_DEAD)
				embed_organs += embed_organ
		if(!embed_organs)
			user.visible_message("<span class='warning'>The [BP.name] seems to already be in fine condition!</span>")
			return
		msg = "<span class='notice'>[user] starts applying medication to the affected tissue in [target]'s [BP.name] with \the [tool].</span>"
		self_msg = "<span class='notice'>You start applying medication to the affected tissue in [target]'s [BP.name] with \the [tool].</span>"
		user.visible_message(msg, self_msg)

	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!")

	return ..()

/datum/surgery_step/organ_manipulation/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(BP.bodypart_organs.len)
		var/list/embed_organs = list()
		for(var/embed_organ in BP.bodypart_organs)
			var/obj/item/organ/internal/IO = embed_organ
			if(IO.status & ORGAN_DEAD)
				embed_organs += embed_organ
		for(var/atom/embed_organ as anything in embed_organs)
			embed_organs[embed_organ] = image(icon = embed_organ.icon, icon_state = initial(embed_organ.icon_state))
		var/choosen_organ = show_radial_menu(user, target, embed_organs, radius = 50, require_near = TRUE, tooltips = TRUE)
		if(!choosen_organ)
			user.visible_message("<span class='warning'>The [BP.name] seems to already be in fine condition!</span>")
			return

		var/obj/item/organ/internal/IO = choosen_organ
		var/obj/item/weapon/reagent_containers/container = tool

		if(container.reagents.has_reagent("peridaxon"))
			var/trans = container.treat_organ(target)
			IO.status &= ~ORGAN_DEAD
			IO.germ_level = 0
			IO.damage = 0

			msg = "<span class='notice'>[user] applies [trans] units of the solution to affected tissue in [target]'s [BP.name]</span>"
			self_msg = "<span class='notice'>You apply [trans] units of the solution to affected tissue in [target]'s [BP.name] with \the [tool].</span>"
			user.visible_message(msg, self_msg)

	return

/datum/surgery_step/organ_manipulation/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)

	if(!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target)	//technically it's contact, but the reagents are being applied to internal tissue

	msg = "<span class='warning'>[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [BP.name] with the [tool]!</span>"
	self_msg = "<span class='warning'>Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [BP.name] with the [tool]!</span>"
	user.visible_message(msg, self_msg)
	//no damage or anything, just wastes medicine

	return

//Procedures in this file: limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/limb
/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(target_zone in list(O_EYES , O_MOUTH))
		return FALSE
	if(target_zone != BP_CHEST && isstump(BP))
		return TRUE
	return FALSE

/datum/surgery_step/limb/attach
	allowed_tools = list(
	/obj/item/organ/external = 100,
	/obj/item/robot_parts = 100,
	)
	allowed_species = null

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		if(BP.open == BP_RETRACT_OS)
			if(istype(tool, /obj/item/robot_parts))
				var/obj/item/robot_parts/p = tool
				if(target_zone != p.part)
					to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
					return FALSE
				if(!p.can_attach())
					to_chat(user, "<span class='userdanger'>You need to attach a flash to [p] first!</span>")
					return FALSE
				return TRUE
			if(isbodypart(tool))
				var/obj/item/organ/external/p = tool
				if(target_zone != p.body_zone)
					to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
					return FALSE
				if(!p.is_compatible(target))
					to_chat(user, "<span class='userdanger'>This does not fit!</span>")
					return FALSE
				return TRUE

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
//				EYE SURGERY manipulation for eyes				//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/organ_manipulation/place_eye
	priority = 2
	allowed_tools = list(
		/obj/item/organ/internal/eyes = 100
		)

	allowed_species = list("exclude", IPC, DIONA)

	min_duration = 12 SECONDS
	max_duration = 16 SECOND

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
