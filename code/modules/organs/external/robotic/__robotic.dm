var/global/list/robotic_controllers_by_company = list()

/datum/bodypart_controller/robot
	name = "robotic"
	var/company = "Unbranded"                            // Shown when selecting the limb.
	var/desc = "A generic unbranded robotic prosthesis." // Seen when examining a limb.
	var/iconbase = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	bodypart_type = BODYPART_ROBOTIC

	var/allowed_states = list("Prothesis")

	var/speed_mod = 0                                   // If it modifies owner's speed.
	var/brute_mod = 1.0
	var/burn_mod = 1.0
	var/carry_weight = 5 * ITEM_SIZE_NORMAL             // Can be a chasis for slightly bigger amount of stuff.

	var/carry_speed_mod = 0                             // This is by how much this prosthetic lowers movement delay of heavy clothing, if such is present.

	var/list/restrict_species = list("exclude")         // Species that CAN wear the limb.

	var/mental_load = 10                                // How much we take from the mob.
	var/processing_language = "Tradeband"               // If processing languages differ, or the mob doesn't understand it - increases mental load.

	var/protected = 0                                   // How protected from EMP the limb is.
	var/low_quality = FALSE                             // If TRUE, limb may spawn in being sabotaged.

	var/parts = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG) // Defines what parts said brand can replace on a body.

	var/monitor = FALSE                                 // Whether the limb can display IPC screens.

	var/tech_tier = LOW_TECH_PROSTHETIC

/datum/bodypart_controller/robot/New(obj/item/organ/external/B)
	if(!B) // Roundstart initiation or something.
		return

	..()
	BP.name = "[company] [BP.name]"
	BP.desc = "This model seems to be made by [company]"

/datum/bodypart_controller/robot/update_sprite()
	var/gender = BP.owner ? BP.owner.gender : MALE
	var/g
	if(BP.body_zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
		g = (gender == FEMALE ? "f" : "m")
	if(!BP.species.has_gendered_icons)
		g = null
	BP.icon = iconbase
	BP.icon_state = "[BP.body_zone][g ? "_[g]" : ""]"

/datum/bodypart_controller/proc/get_pos_parts(species)
	return list()

/datum/bodypart_controller/robot/proc/get_pos_parts(species)
	if(species == IPC)
		return BP_ALL
	return parts

/datum/bodypart_controller/robot/is_damageable(additional_damage = 0)
	return TRUE // Robot organs don't count towards total damage so no need to cap them.

/datum/bodypart_controller/robot/get_carry_weight()
	return carry_weight

/datum/bodypart_controller/robot/get_brute_mod()
	return brute_mod

/datum/bodypart_controller/robot/get_burn_mod()
	return burn_mod

/datum/bodypart_controller/robot/emp_act(severity)
	var/burn_damage = 0

	if(protected)
		severity = min(severity + protected, 3)
	if(BP.sabotaged)
		severity = max(severity - 1, 1)

	switch(severity)
		if(1)
			if(prob(30))
				processing_language = pick(global.all_languages) // To screw with the person even more.
			burn_damage = 15
		if(2)
			burn_damage = 7
		if(3)
			burn_damage = 3

	if(burn_damage)
		BP.take_damage(null, burn_damage)

/datum/bodypart_controller/robot/need_process()
	return TRUE // If it's robotic, that's fine it will have a status.

/datum/bodypart_controller/robot/update_germs()
	BP.germ_level = 0
	return

/datum/bodypart_controller/robot/update_wounds() //Robotic limbs don't heal or get worse.
	if(BP.sabotaged && tech_tier < HIGH_TECH_PROSTHETIC)
		explosion(get_turf(BP.owner), -1, -1, 2, 3)
		var/datum/effect/effect/system/spark_spread/spark_system = new
		spark_system.set_up(5, 0, BP.owner)
		spark_system.attach(BP.owner)
		spark_system.start()
		QDEL_IN(spark_system, 1 SECOND)

	for(var/datum/wound/W in BP.wounds) //Repaired wounds disappear though
		if(W.damage <= 0)  //and they disappear right away
			BP.wounds -= W    //TODO: robot wounds for robot limbs
	return

/datum/bodypart_controller/robot/update_damages()
	BP.number_wounds = 0
	BP.brute_dam = 0
	BP.burn_dam = 0
	BP.status &= ~ORGAN_BLEEDING

	//update damage counts
	for(var/datum/wound/W in BP.wounds)
		if(W.damage_type == BURN)
			BP.burn_dam += W.damage
		else
			BP.brute_dam += W.damage
		BP.number_wounds += W.amount

/datum/bodypart_controller/robot/damage_state_color()
	return "#888888"

/datum/bodypart_controller/robot/sever_artery()
	return FALSE

/datum/bodypart_controller/robot/fracture()
	return

/datum/bodypart_controller/robot/handle_cut()
	BP.owner.update_weight()
	BP.owner.update_mental_load()

/datum/bodypart_controller/robot/process_outside()
	return

/datum/bodypart_controller/robot/check_rejection()
	return

/datum/bodypart_controller/robot/handle_rejection()
	return

/obj/item/organ/external/chest/robot
	name = "robotic chest"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "chest_m"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/head/robot
	name = "robotic head"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "head_m"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/groin/robot
	name = "robotic groin"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "groin_m"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/l_arm/robot
	name = "robotic left arm"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "l_arm"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/r_arm/robot
	name = "robotic right arm"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "r_arm"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/r_leg/robot
	name = "robotic right leg"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "r_leg"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/l_leg/robot
	name = "robotic left leg"

	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	icon_state = "l_leg"

	controller_type = /datum/bodypart_controller/robot
