/datum/bodypart_controller/skeleton
	name = "Skeleton bodypart controller"
	bodypart_type = BODYPART_SKELETON

/datum/bodypart_controller/skeleton/is_damageable(additional_damage = 0)
	return TRUE

/datum/bodypart_controller/skeleton/emp_act(severity)
	return

// Bones just fly away if damage is too high. They also don't care about lasers
/datum/bodypart_controller/skeleton/take_damage(brute = 0, burn = 0, damage_flags = 0, used_weapon = null)
	brute = round(brute * BP.owner.species.brute_mod, 0.1)

	if(brute <= 0)
		return 0

	playsound(BP.owner, pick(SOUNDIN_BONEBREAK), VOL_EFFECTS_MASTER, null, null, -2)

	var/lose_bone_chance = 100
	if(brute < BP.min_broken_damage * 2)
		lose_bone_chance = 20
	else if(brute < BP.min_broken_damage)
		lose_bone_chance = 5

	if(prob(lose_bone_chance))
		if(!BP.cannot_amputate)
			BP.droplimb(null, null, DROPLIMB_EDGE)
		else if(BP.children.len) // hitting the chest will drop random attached bone
			var/obj/item/organ/external/OBP = pick(BP.children)
			OBP.droplimb(null, null, DROPLIMB_EDGE)

/datum/bodypart_controller/skeleton/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	return

// Bones have no wounds
/datum/bodypart_controller/skeleton/createwound(type = CUT, damage)
	return

/datum/bodypart_controller/skeleton/need_process()
	return FALSE

/datum/bodypart_controller/skeleton/process()
	return

/datum/bodypart_controller/skeleton/update_damages()
	return

/datum/bodypart_controller/skeleton/sever_artery()
	return

/datum/bodypart_controller/skeleton/fracture()
	return

/datum/bodypart_controller/skeleton/handle_cut()
	return

/datum/bodypart_controller/skeleton/process_outside()
	return

// If you attach these bones to any other species they just won't work, because magic
/datum/bodypart_controller/skeleton/check_rejection()
	if(BP.owner.species.name == BP.species.name)
		BP.is_rejecting = FALSE
	else
		BP.is_rejecting = TRUE

/datum/bodypart_controller/skeleton/handle_rejection()
	return

/proc/skeleton_insert_bodypart(mob/M, obj/item/organ/external/BP, target_zone)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(H.species.name != BP.species.name)
		return
	if(H.bodyparts_by_name[BP.body_zone])
		return
	if(BP.parent_bodypart && !H.bodyparts_by_name[BP.parent_bodypart])
		return

	usr.remove_from_mob(BP)
	BP.insert_organ(H)
	H.update_body()
	H.updatehealth()
	H.UpdateDamageIcon(BP)

	if(istype(BP, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/B = BP
		if (B.brainmob && B.brainmob.mind)
			B.brainmob.mind.transfer_to(H)
			H.dna = B.brainmob.dna
			QDEL_NULL(B.brainmob)

	H.visible_message("<span class='notice'>[usr] attached [BP.name] to [M]</span>")

	return TRUE

// BODYPARTS
/obj/item/organ/external/chest/skeleton
	name = "skeleton chest"
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 15
	controller_type = /datum/bodypart_controller/skeleton

/obj/item/organ/external/chest/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()

/obj/item/organ/external/head/skeleton
	name = "skeleton head"
	vital = FALSE
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 20
	controller_type = /datum/bodypart_controller/skeleton

/obj/item/organ/external/head/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()

/obj/item/organ/external/groin/skeleton
	name = "skeleton groin"
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 15
	controller_type = /datum/bodypart_controller/skeleton

	cannot_amputate = FALSE
	vital = FALSE

/obj/item/organ/external/groin/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()

/obj/item/organ/external/l_arm/skeleton
	name = "skeleton left arm"
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 10
	controller_type = /datum/bodypart_controller/skeleton

/obj/item/organ/external/l_arm/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()

/obj/item/organ/external/r_arm/skeleton
	name = "skeleton right arm"
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 10
	controller_type = /datum/bodypart_controller/skeleton

/obj/item/organ/external/r_arm/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()

/obj/item/organ/external/r_leg/skeleton
	name = "skeleton right leg"
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 10
	controller_type = /datum/bodypart_controller/skeleton

/obj/item/organ/external/r_leg/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()

/obj/item/organ/external/l_leg/skeleton
	name = "skeleton left leg"
	leaves_stump = FALSE
	force = 8
	min_broken_damage = 10
	controller_type = /datum/bodypart_controller/skeleton

/obj/item/organ/external/l_leg/skeleton/attack(mob/living/M, mob/living/user, def_zone)
	if(!skeleton_insert_bodypart(M, src, def_zone))
		. = ..()