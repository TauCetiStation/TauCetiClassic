/datum/bodypart_controller/robot
	name = "Robotic bodypart controller"
	bodypart_type = BODYPART_ROBOTIC
	damage_threshold = 1

/datum/bodypart_controller/robot/is_damageable(additional_damage = 0)
	return TRUE // Robot organs don't count towards total damage so no need to cap them.

/datum/bodypart_controller/robot/emp_act(severity)
	var/burn_damage = 0
	switch(severity)
		if(1)
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
	return

/datum/bodypart_controller/robot/process_outside()
	return

/datum/bodypart_controller/robot/check_rejection()
	return

/datum/bodypart_controller/robot/handle_rejection()
	return

/obj/item/organ/external/chest/robot
	name = "robotic chest"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "chest_m"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/chest/robot/update_sprite()
	return

/obj/item/organ/external/head/robot
	name = "robotic head"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "head_m"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/head/robot/update_sprite()
	return

/obj/item/organ/external/groin/robot
	name = "robotic groin"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "groin_m"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/groin/robot/update_sprite()
	return

/obj/item/organ/external/l_arm/robot
	name = "robotic left arm"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "l_arm"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/l_arm/robot/update_sprite()
	return

/obj/item/organ/external/r_arm/robot
	name = "robotic right arm"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "r_arm"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/r_arm/robot/update_sprite()
	return

/obj/item/organ/external/r_leg/robot
	name = "robotic right leg"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "r_leg"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/r_leg/robot/update_sprite()
	return

/obj/item/organ/external/l_leg/robot
	name = "robotic left leg"

	icon = 'icons/mob/human_races/robotic.dmi'
	icon_state = "l_leg"

	controller_type = /datum/bodypart_controller/robot

/obj/item/organ/external/l_leg/robot/update_sprite()
	return