/obj/mecha/combat/phazon
	desc = "An exosuit which can only be described as 'WTF?'."
	name = "Phazon"
	icon_state = "phazon"
	initial_icon = "phazon"
	step_in = 1
	dir_in = 1 //Facing North.
	step_energy_drain = 3
	health = 200
	deflect_chance = 30
	damage_absorption = list(BRUTE=0.7,BURN=0.7,BULLET=0.7,LASER=0.7,ENERGY=0.7,BOMB=0.7)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = /obj/effect/decal/mecha_wreckage/phazon
	add_req_access = 1
	//operation_req_access = list()
	internal_damage_threshold = 25
	force = 15
	var/phasing = FALSE
	var/phasing_energy_drain = 200
	var/datum/action/innate/mecha/mech_switch_damtype/switch_damtype_action = new
	var/datum/action/innate/mecha/mech_toggle_phasing/phasing_action = new
	max_equip = 4

/obj/mecha/combat/phazon/Destroy()
	QDEL_NULL(switch_damtype_action)
	QDEL_NULL(phasing_action)
	return ..()

/obj/mecha/combat/phazon/GrantActions(mob/living/user, human_occupant = 0)
	..()
	switch_damtype_action.Grant(user, src)
	phasing_action.Grant(user, src)

/obj/mecha/combat/phazon/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	switch_damtype_action.Remove(user)
	phasing_action.Remove(user)


/obj/mecha/combat/phazon/atom_init()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult
	ME.attach(src)
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 12000, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))

/obj/mecha/combat/phazon/Bump(atom/obstacle)
	if(phasing && get_charge()>=phasing_energy_drain)
		if(can_move)
			can_move = 0
			flick("phazon-phase", src)
			src.loc = get_step(src,src.dir)
			use_power(phasing_energy_drain)
			sleep(step_in*3)
			can_move = 1
	else
		. = ..()
	return

/obj/mecha/combat/phazon/click_action(atom/target,mob/user)
	if(phasing)
		occupant_message("Unable to interact with objects while phasing")
		return
	else
		return ..()

/obj/mecha/combat/phazon/proc/switch_damtype()
	if(usr != src.occupant)
		return
	var/new_damtype
	var/color_message
	switch(damtype)
		if(TOX)
			new_damtype = BRUTE
			color_message = "red"
		if(BRUTE)
			new_damtype = BURN
			color_message = "orange"
		if(BURN)
			new_damtype = TOX
			color_message = "green"
	damtype = new_damtype
	occupant_message("Melee damage type switched to <font color='[color_message]'>[new_damtype].</font>")
	return

/obj/mecha/combat/phazon/proc/switch_phasing()
	phasing = !phasing
	send_byjax(src.occupant,"exosuit.browser","phasing_command","[phasing?"Dis":"En"]able phasing")
	occupant_message("<font color=\"[phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")

/obj/mecha/combat/phazon/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];phasing=1'><span id="phasing_command">[phasing?"Dis":"En"]able phasing</span></a><br>
						<a href='?src=\ref[src];switch_damtype=1'>Change melee damage type</a><br>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/phazon/Topic(href, href_list)
	..()
	if (href_list["switch_damtype"])
		switch_damtype()
	if (href_list["phasing"])
		switch_phasing()
	return

/obj/mecha/combat/phazon/captain/atom_init() // for aspect
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult(src)
	ME.attach(src)
