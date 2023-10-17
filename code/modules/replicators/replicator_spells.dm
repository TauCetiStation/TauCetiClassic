/obj/effect/proc_holder/spell/no_target/replicator_construct
	var/material_cost = 0
	var/objection_delay = 0

	var/remembered_ckey = ""

/obj/effect/proc_holder/spell/no_target/replicator_construct/atom_init()
	. = ..()
	name = "[name] ([material_cost])"

/obj/effect/proc_holder/spell/no_target/replicator_construct/proc/replicator_checks(mob/user, try_start)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user

	if(remembered_ckey != user_replicator.last_controller_ckey)
		return FALSE

	if(!isfloorturf(user.loc))
		if(try_start)
			to_chat(user, "<span class='notice'>You must be on solid ground to construct this.</span>")
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/no_target/replicator_construct/proc/replicator_checks_do_after_handler(mob/user, atom/target)
	return replicator_checks(user, TRUE)

/obj/effect/proc_holder/spell/no_target/replicator_construct/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(FR.materials < material_cost)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough materials.</span>")
		return FALSE

	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	remembered_ckey = user_replicator.last_controller_ckey

	if(!replicator_checks(user, try_start))
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/proc/objection_timer(mob/living/simple_animal/hostile/replicator/user_replicator, message)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.adjust_materials(-material_cost, adjusted_by=user_replicator.last_controller_ckey)

	var/datum/callback/checks = CALLBACK(src, PROC_REF(replicator_checks_do_after_handler))
	. = user_replicator.do_after_objections(objection_delay, message, extra_checks=checks)
	if(!.)
		FR.adjust_materials(material_cost, adjusted_by=user_replicator.last_controller_ckey)
	else
		user_replicator.announce_material_adjustment(-material_cost)


/obj/effect/proc_holder/spell/no_target/replicator_construct/replicate
	name = "Replicate"
	desc = "Create a drone for the swarm."

	charge_type = "recharge"
	charge_max = 10 SECONDS

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_replicate"

	material_cost = REPLICATOR_COST_REPLICATE
	// objection_delay = 3 SECONDS

/obj/effect/proc_holder/spell/no_target/replicator_construct/replicate/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(length(global.alive_replicators) + FR.bandwidth_borrowed >= FR.bandwidth)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough bandwidth for replication.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/replicate/replicator_checks(mob/user, try_start)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(length(global.alive_replicators) + FR.bandwidth_borrowed > FR.bandwidth)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough bandwidth for replication.</span>")
		return FALSE

	var/node_proximity = FALSE
	for(var/obj/structure/forcefield_node/FN as anything in global.forcefield_nodes)
		if(get_dist(FN, src) >= 2)
			continue
		if(locate(/obj/machinery/power/replicator_generator) in FN.loc)
			continue
		node_proximity = TRUE
		break

	if(!node_proximity)
		if(try_start)
			to_chat(user, "<span class='warning'>You require an unclaimed node adjacent to you to replicate.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/replicate/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/callback/checks = CALLBACK(src, PROC_REF(replicator_checks_do_after_handler))

	FR.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)
	FR.bandwidth_borrowed += 1
	// to-do: (replicators) add a sound here. I don't know what replication should sound like
	to_chat(user_replicator, "<span class='notice'>Initiating replication protocols...</span>")
	if(!do_after(user_replicator, 3 SECONDS, target=user_replicator, extra_checks=checks))
		FR.adjust_materials(material_cost, adjusted_by=user_replicator.ckey)
		FR.bandwidth_borrowed -= 1
		return

	FR.bandwidth_borrowed -= 1

	user_replicator.announce_material_adjustment(-material_cost)

	var/mob/living/simple_animal/hostile/replicator/R = new(user_replicator.loc)
	R.set_last_controller(user_replicator.last_controller_ckey, just_spawned=TRUE)

	if(length(user_replicator.generation) < 10)
		R.generation = "[user_replicator.generation][rand(0, 9)]"
		R.name = "replicator ([R.generation])"
		R.real_name = R.name
		R.chat_color_name = R.name

	R.next_control_change = world.time + R.control_change_cooldown

	if(user_replicator.a_intent == INTENT_HARM)
		R.set_leader(user_replicator)

	var/datum/replicator_array_info/RAI = FR.ckey2info[user_replicator.last_controller_ckey]
	if(RAI)
		RAI.replicated_times += 1

	to_chat(user, "<span class='notice'>Replication successful, meet [R.name]!</span>")
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/replicator_construct/barricade
	name = "Barricade"
	desc = "Construct a barricade that replicators can pass through."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_barricade"

	material_cost = REPLICATOR_COST_BARRICADE

/obj/effect/proc_holder/spell/no_target/replicator_construct/barricade/replicator_checks(mob/user, try_start)
	var/turf/my_turf = get_turf(user)
	if((locate(/obj/structure/replicator_forcefield) in my_turf) || (locate(/obj/structure/replicator_barricade) in my_turf))
		if(try_start)
			to_chat(user, "<span class='notice'>This tile is already protected.</span>")
		return FALSE

	if(locate(/obj/machinery/swarm_powered/bluespace_transponder) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the barricade.</span>")
		return FALSE

	if(locate(/obj/machinery/power/replicator_generator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the barricade.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/barricade/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>Barricade deployed successfully.</span>")

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)
	user_replicator.announce_material_adjustment(-material_cost)

	var/datum/replicator_array_info/RAI = FR.ckey2info[user_replicator.last_controller_ckey]
	if(RAI)
		RAI.barricades_built += 1

	new /obj/structure/replicator_barricade(user_replicator.loc)
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/replicator_construct/trap
	name = "Trap"
	desc = "Constructs a multi-use trap, that stuns and electrocutes enemies."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_trap"

	material_cost = REPLICATOR_COST_MINE

/obj/effect/proc_holder/spell/no_target/replicator_construct/trap/replicator_checks(mob/user, try_start)
	if(locate(/obj/item/mine/replicator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>There is already a trap here.</span>")
		return FALSE

	for(var/mine_dir in global.cardinal)
		var/turf/T = get_step(user.loc, mine_dir)
		if(locate(/obj/item/mine/replicator) in T)
			if(try_start)
				to_chat(user, "<span class='notice'>Can not place mines cardinally adjacent to other mines.</span>")
			return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/trap/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>Mine deployed successfully.</span>")

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)
	user_replicator.announce_material_adjustment(-material_cost)

	var/datum/replicator_array_info/RAI = FR.ckey2info[user_replicator.last_controller_ckey]
	if(RAI)
		RAI.traps_built += 1

	var/obj/item/mine/replicator/trap = new(user_replicator.loc)
	trap.creator_ckey = user_replicator.last_controller_ckey
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/replicator_construct/transponder
	name = "Emit"
	desc = "Create a transponder for the swarm. Transponders start consuming resources only after at least 150 have been accumulated."

	charge_type = "recharge"
	charge_max = 10 SECONDS

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_transponder"

	material_cost = REPLICATOR_COST_REPLICATE
	objection_delay = 3 SECONDS

/obj/effect/proc_holder/spell/no_target/replicator_construct/transponder/replicator_checks(mob/user, try_start)
	if(locate(/obj/machinery/swarm_powered/bluespace_transponder) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the transponder, there is a trasponder here already.</span>")
		return FALSE

	if(locate(/obj/machinery/power/replicator_generator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the transponder, a generator is in the way.</span>")
		return FALSE

	if(locate(/obj/structure/forcefield_node) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Can not construct a transponder here because of the node.</span>")
		return FALSE

	for(var/bt in global.transponders)
		if(get_dist(bt, user) >= 7)
			continue
		if(try_start)
			to_chat(user, "<span class='notice'>Transponder too close to other transponders. Need at least 7 tile distance.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/transponder/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	var/area/A = get_area(user_replicator)
	// to-do: (replicators) add a sound here.
	if(!objection_timer(user_replicator, "Deploying a bluespace transponder at [A.name]."))
		return

	to_chat(user, "<span class='notice'>Bluespace Transponder activation initiated...Establishing contact with The Swarm.</span>")

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[user_replicator.last_controller_ckey]
	if(RAI)
		RAI.transponders_built += 1

	var/obj/machinery/swarm_powered/bluespace_transponder/BT = new(user_replicator.loc)
	BT.name = "[BT.name] ([user_replicator.generation][rand(0, 9)])"
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)

	if(user_replicator.auto_construct_type != /obj/structure/bluespace_corridor)
		return
	if(!isturf(user_replicator.loc))
		return
	user_replicator.try_construct(user_replicator.loc)


/obj/effect/proc_holder/spell/no_target/replicator_construct/generator
	name = "Construct Generator"
	desc = "Construct a generator to power transponders."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_generator"

	material_cost = REPLICATOR_COST_REPLICATE
	objection_delay = 3 SECONDS

/obj/effect/proc_holder/spell/no_target/replicator_construct/generator/replicator_checks(mob/user, try_start)
	if(locate(/obj/machinery/swarm_powered/bluespace_transponder) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the generator, a transponder is in the way.</span>")
		return FALSE

	if(locate(/obj/machinery/power/replicator_generator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the generator, another generator is already here.</span>")
		return FALSE

	var/obj/structure/forcefield_node/FN = locate() in user.loc
	if(!FN)
		if(try_start)
			to_chat(user, "<span class='notice'>The generator requires a node to attach to.</span>")
		return FALSE

	if(!FN.captured())
		if(try_start)
			to_chat(user, "<span class='notice'>The node must be captured by walking to it through a bluespace corridor first.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/generator/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	var/area/A = get_area(user_replicator)
	// to-do: (replicators) add a sound here.
	if(!objection_timer(user_replicator, "Deploying a generator at [A.name]."))
		return

	to_chat(user, "<span class='notice'>Generator deployed.</span>")
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[user_replicator.last_controller_ckey]
	if(RAI)
		RAI.generators_built += 1

	var/obj/machinery/power/replicator_generator/BG = new(user_replicator.loc)
	BG.name = "[BG.name] ([user_replicator.generation][rand(0, 9)])"
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction
	name = "Toggle Web Construction (1)"
	desc = "Toggle auto construction of the Bluespace Web."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_corridor"

/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(FR.materials < 1)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough materials.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	if(!user_replicator.auto_construct_type)
		user_replicator.auto_construct_type = /obj/structure/bluespace_corridor
		user_replicator.auto_construct_cost = 1
		to_chat(user_replicator, "<span class='notice'>You toggle web construction on.</span>")

		if(isturf(user_replicator.loc))
			user_replicator.try_construct(user_replicator.loc)

		action.button_icon_state = "ui_corridor_on"
		action.button.UpdateIcon()
		user.playsound_local(src, 'sound/effects/click_on.ogg', VOL_EFFECTS_MASTER, 25, FALSE)
	else
		user_replicator.auto_construct_type = null
		user_replicator.auto_construct_cost = 0
		to_chat(user_replicator, "<span class='notice'>You toggle web construction off.</span>")

		action.button_icon_state = "ui_corridor"
		action.button.UpdateIcon()
		user.playsound_local(src, 'sound/effects/click_off.ogg', VOL_EFFECTS_MASTER, 25, FALSE)


/obj/effect/proc_holder/spell/no_target/transfer_to_idle
	name = "Idle Transfer"
	desc = "Transfer to an idle member of the swarm."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_transfer_idle"

	stat_allowed = TRUE

/obj/effect/proc_holder/spell/no_target/transfer_to_idle/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(length(global.idle_replicators) <= 0)
		if(try_start)
			to_chat(user, "<span class='notice'>No suitable hosts found.</span>")
		return FALSE

	if(user.stat == DEAD)
		if(try_start)
			to_chat(user, "Not when you're incapacitated.")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/transfer_to_idle/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	if(user_replicator.transfer_control(pick(global.idle_replicators)))
		to_chat(user, "<span class='notice'>TRANSFERING...</span>")


/obj/effect/proc_holder/spell/no_target/transfer_to_area
	name = "Area Transfer"
	desc = "Transfer to a replicator from an area."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_transfer_area"

	stat_allowed = TRUE

/obj/effect/proc_holder/spell/no_target/transfer_to_area/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(user.stat == DEAD)
		if(try_start)
			to_chat(user, "Not when you're incapacitated.")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/transfer_to_area/cast(list/targets, mob/user = usr)
	var/list/pos_areas = list()

	for(var/r in global.alive_replicators)
		var/mob/living/simple_animal/hostile/replicator/R = r
		if(R.is_controlled() || R.incapacitated())
			continue
		var/area/A = get_area(R)
		pos_areas[A.name] = A

	if(length(pos_areas) <= 0)
		to_chat(user, "<span class='notice'>No suitable hosts found.</span>")
		return FALSE

	var/area_name = tgui_input_list(user, "Choose an area with replicators in it.", "Area Transfer", pos_areas)
	if(!area_name)
		charge_counter = charge_max
		return FALSE

	var/area/thearea = pos_areas[area_name]

	for(var/mob/living/simple_animal/hostile/replicator/R in thearea)
		if(R == user)
			continue
		var/mob/living/simple_animal/hostile/replicator/user_replicator = user
		if(user_replicator.transfer_control(R))
			to_chat(user, "<span class='notice'>TRANSFERING...</span>")
			return

	to_chat(user, "<span class='notice'>No suitable hosts found in area.</span>")
	charge_counter = charge_max

/obj/effect/proc_holder/spell/no_target/toggle_light
	name = "Toggle Light"
	desc = "Toggle a light to see in dark areas."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_light"

	var/on = FALSE

/obj/effect/proc_holder/spell/no_target/toggle_light/cast(list/targets, mob/user = usr)
	on = !on
	if(on)
		set_light(2)
		user.playsound_local(src, 'sound/effects/click_on.ogg', VOL_EFFECTS_MASTER, 25, FALSE)
	else
		set_light(0)
		user.playsound_local(src, 'sound/effects/click_off.ogg', VOL_EFFECTS_MASTER, 25, FALSE)


/obj/effect/proc_holder/spell/no_target/set_mail_tag
	name = "Set Mail Tag"
	desc = "Tag yourself for delivery through the disposals system."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_mail"

/obj/effect/proc_holder/spell/no_target/set_mail_tag/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user

	var/new_tag = input("Select the desired destination.", "Set Mail Tag", null) as null|anything in tagger_locations
	if(!new_tag)
		user_replicator.mail_destination = ""
		return

	to_chat(user, "<span class='notice'>You configure your internal beacon, tagging yourself for delivery to '[new_tag]'.</span>")
	user_replicator.mail_destination = new_tag

	user_replicator.try_enter_disposal_system()


/obj/effect/proc_holder/spell/no_target/replicator_construct/catapult
	name = "Open Bluespace Rift"
	desc = "Produce a device to open the bluespace rift. Rift will then consume energy and materials until completed."

	charge_type = "recharge"
	charge_max = 1 MINUTE

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_catapult"

	material_cost = 0
	objection_delay = 10 SECONDS

/obj/effect/proc_holder/spell/no_target/replicator_construct/catapult/replicator_checks(mob/user, try_start)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(FR.bandwidth < 20)
		if(try_start)
			to_chat(user, "<span class='warning'>The rift requires 20 replicators to be sent through. You need more bandwidth.</span>")
		return FALSE

	if(length(global.bluespace_catapults) > 0)
		if(try_start)
			var/area/A = get_area(pick(global.bluespace_catapults))
			to_chat(user, "<span class='notice'>You already have a catapult being built in [A.name]. Protect it!</span>")
		return FALSE

	if(!is_station_level(user.z))
		if(try_start)
			to_chat(user, "<span class='notice'>The rift must be opened aboard NSS Exodus.</span>")
		return FALSE

	var/area/A = get_area(user)
	if(!(A.name in teleportlocs))
		if(try_start)
			to_chat(user, "<span class='notice'>Only inhabitable areas may be used to open a rift.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_construct/catapult/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/replicator/user_replicator = user
	var/area/A = get_area(user_replicator)
	// to-do: (replicators) add a sound here. something ominous and loud, everyone should know that the end is about to begin
	if(!objection_timer(user_replicator, "Constructing a Bluespace Catapult at [A.name]!"))
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[user_replicator.last_controller_ckey]
	if(RAI)
		RAI.catapults_built += 1

	new /obj/machinery/swarm_powered/bluespace_catapult(user_replicator.loc)
	to_chat(user_replicator, "<span class='notice'>SPAWNING... What have you done.</span>")
	playsound(user_replicator, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)
