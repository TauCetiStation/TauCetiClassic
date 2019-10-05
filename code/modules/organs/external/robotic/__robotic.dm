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

	var/list/built_in_tools = null // A list of format list("tool_name" = tool_type), after roundstart becomes list("tool_name" = tool_obj). Do "hand" = null to still allow unarmed attacks.
	var/selected_tool = null
	var/default_selected_tool = "hand"

	var/list/restrict_species = list("exclude")         // Species that CAN wear the limb.

	var/mental_load = 10                                // How much we take from the mob.
	var/processing_language = "Tradeband"               // If processing languages differ, or the mob doesn't understand it - increases mental load.

	var/protected = 0                                   // How protected from EMP the limb is.
	var/low_quality = FALSE                             // If TRUE, limb may spawn in being sabotaged.

	var/list/parts = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG) // Defines what parts said brand can replace on a body.
	var/list/ipc_parts = BP_ALL

	var/monitor = FALSE                                 // Whether the limb can display IPC screens.

	var/default_cell_type
	var/passive_cell_use = 0
	var/action_cell_use = 0

	var/tech_tier = LOW_TECH_PROSTHETIC
	var/start_rejecting_after = 0
	var/rejection_time = 10 MINUTES
	var/arr_consume_amount = 0.0 // Anti rejection reagent consume amount.

/datum/bodypart_controller/robot/New(obj/item/organ/external/B)
	if(!B) // Roundstart initiation or something.
		return

	if(B.is_arm && built_in_tools)
		B.action_button_name = "Switch arm-tool."
		B.action = new /datum/action/prosthetic_tool_switch(B)
		B.action.name = B.action_button_name

	..()

	if(built_in_tools)
		var/list/new_built_in_tools = list()
		for(var/tool_name in built_in_tools)
			var/tool_type = built_in_tools[tool_name]
			var/obj/item/I
			if(tool_type)
				I = new tool_type(BP)
				I.flags |= ABSTRACT|NODROP
			new_built_in_tools[tool_name] = I
		built_in_tools = new_built_in_tools
		selected_tool = default_selected_tool

	start_rejecting_after = world.time + rejection_time
	BP.name = "[company] [BP.name]"
	BP.desc = "This model seems to be made by [company]"

	if(passive_cell_use > 0 || action_cell_use > 0 && default_cell_type)
		BP.add_cell(new default_cell_type)
		BP.cell_activate()

/datum/bodypart_controller/robot/Destroy()
	for(var/tool_name in built_in_tools)
		qdel(built_in_tools[tool_name])
	built_in_tools = null
	return ..()

/datum/bodypart_controller/robot/get_inspect_string(mob/living/inspector)
	if(inspector == BP.owner && BP.cell)
		return "<span class='notice'> Charge is at <span class='[BP.cell.percent() > 50 ? "notice" : "warning"]'>[round(BP.cell.percent(), 5)]%</span></span>"
	return ""

/datum/bodypart_controller/robot/update_sprite()
	var/gender = BP.owner ? BP.owner.gender : MALE
	var/g
	if(BP.body_zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
		g = (gender == FEMALE ? "f" : "m")
	if(!BP.species.has_gendered_icons)
		g = null
	BP.icon = iconbase
	BP.icon_state = "[BP.body_zone][g ? "_[g]" : ""]"

/datum/bodypart_controller/robot/is_usable()
	if(passive_cell_use > 0 || action_cell_use > 0)
		if(!BP.cell)
			return FALSE
		if(BP.cell.charge <= 0)
			return FALSE
		if(!BP.cell_active)
			return FALSE
	return !(BP.status & (ORGAN_MUTATED|ORGAN_DEAD))

/datum/bodypart_controller/robot/handleUnarmedAttack(atom/target)
	if(action_cell_use > 0 && !BP.cell_use_power(action_cell_use))
		BP.owner.visible_message("<span class='warning'>[BP] screeches as it tries to move.</span>")
		return TRUE
	if((passive_cell_use > 0 || action_cell_use > 0) && BP.owner.a_intent == I_GRAB && target != BP.owner)
		var/obj/item/weapon/stock_parts/cell/C
		if(istype(target, /obj/item/weapon/stock_parts/cell))
			C = target
		else if(istype(target, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = target
			C = A.cell
		else if(ishuman(target))
			var/mob/living/carbon/human/H = target
			for(var/obj/item/organ/external/pos_char in H.bodyparts)
				if(pos_char.cell)
					C = pos_char.cell
					break
		else if(istype(target, /obj/item))
			var/obj/item/I = target
			if(I.cell)
				C = I.cell

		if(C)
			BP.owner.visible_message("<span class='notice'>[BP.owner] inserts their [BP] into [C].</span>", "<span class='notice'>You start charging from [C].</span>")
			charge_tries:
				for(var/i in 1 to 50)
					if(BP.owner.is_busy() || !do_after(BP.owner, 5, target = target))
						break charge_tries
					bodypart_loop:
						for(var/obj/item/organ/external/to_char in BP.owner.bodyparts)
							if(istype(to_char.controller, /datum/bodypart_controller/robot))
								var/datum/bodypart_controller/robot/R_cont = to_char.controller
								if(R_cont.passive_cell_use <= 0 || R_cont.action_cell_use <= 0)
									continue bodypart_loop
								if(to_char.cell.charge < to_char.cell.maxcharge)
									if(C.cell_use_power(10))
										to_char.cell_set_charge(to_char.cell.charge + 10)
										continue charge_tries
									else
										break charge_tries
			return TRUE
	return FALSE

/*
/datum/bodypart_controller/robot/handleRangedAttack(atom/target)
	return FALSE
*/

/datum/bodypart_controller/proc/get_pos_parts(species)
	return list()

/datum/bodypart_controller/robot/get_pos_parts(species)
	if(species == IPC)
		return ipc_parts
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
	BP.is_rejecting = TRUE
	var/chances = 100

	if(BP.species.name != IPC && !BP.owner.reagents.get_reagent_amount("neuropozyne"))
		switch(tech_tier)
			if(LOW_TECH_PROSTHETIC)
				chances *= 0.75
			if(MEDIUM_TECH_PROSTHETIC)
				chances *= 0.95
			if(HIGH_TECH_PROSTHETIC)
				chances *= 1.0

		if(BP.sabotaged)
			chances *= 0.5
		if(low_quality)
			chances *= 0.5

	if(prob(chances))
		BP.is_rejecting = FALSE

/datum/bodypart_controller/robot/handle_rejection()
	if(start_rejecting_after < world.time && arr_consume_amount > 0)
		BP.is_rejecting = TRUE
		return

	if(!BP.is_rejecting)
		return

	var/list/pos_arr_regs = list("neuropozyne" = 1.0, "stabyzol" = 0.5, "inaprovaline" = 0.1)
	for(var/pos_arr_reg in pos_arr_regs)
		var/arr = BP.owner.reagents.get_reagent_amount(pos_arr_reg)
		if(arr > arr_consume_amount)
			BP.owner.reagents.remove_reagent("anti_prosthetic_rejection", arr_consume_amount)
			start_rejecting_after = world.time + rejection_time * pos_arr_regs[pos_arr_reg]
			BP.is_rejecting = FALSE
			return

	if(prob(2))
		var/fail_msg = pick("IS ASSUMING DIRECT CONTROL!", "HURTS IMMENSELY!", "IS NO MORE!")
		to_chat(src, "[bicon(BP)] <span class='warning'>[uppertext(BP.name)] [fail_msg]</span>")
		emp_act(1)

	if(prob(2))
		var/fail_msg = pick("HURTS LIKE HECK!", "HURTS A LOT!", "HURTS!")
		to_chat(src, "[bicon(BP)] <span class='warning'>[uppertext(BP.name)] [fail_msg]</span>")
		BP.owner.adjustHalLoss(10)

	if(prob(2))
		to_chat(src, "[bicon(BP)] <span class='warning'>[uppertext(BP.name)] feels as if burning!</span>")
		BP.owner.adjustBrainLoss(5)

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
