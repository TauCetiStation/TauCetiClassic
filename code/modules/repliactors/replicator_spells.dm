/obj/effect/proc_holder/spell/no_target/replicator_replicate
	name = "Replicate (200)"
	desc = "Create a drone for the swarm."

	charge_type = "recharge"
	charge_max = 10 SECONDS

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_replicate"

	var/material_cost = REPLICATOR_COST_REPLICATE

/obj/effect/proc_holder/spell/no_target/replicator_replicate/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(length(global.replicators) >= global.replicators_faction.bandwidth)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough bandwidth for replication.</span>")
		return FALSE

	if(global.replicators_faction.materials < material_cost)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough materials.</span>")
		return FALSE

	// Should fix replicating inside vents which would be buggy...
	if(!istype(user.loc, /turf/simulated/floor))
		if(try_start)
			to_chat(user, "<span class='notice'>You mustn't be inside of anything for this to work.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_replicate/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>SPAWNING...</span>")
	global.replicators_faction.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)

	var/mob/living/simple_animal/replicator/R = new(user_replicator.loc)
	R.last_controller_ckey = user_replicator.last_controller_ckey

	R.generation = "[user_replicator.generation][rand(0, 9)]"

	R.name = "replicator ([R.generation])"
	R.real_name = name

	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/construct_barricade
	name = "Barricade (10)"
	desc = "Construct a barricade that replicators can pass through."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_barricade"

	var/material_cost = 10

/obj/effect/proc_holder/spell/no_target/construct_barricade/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(global.replicators_faction.materials < material_cost)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough materials.</span>")
		return FALSE

	if(!istype(user.loc, /turf/simulated/floor))
		if(try_start)
			to_chat(user, "<span class='notice'>You mustn't be inside of anything for this to work.</span>")
		return FALSE

	var/turf/my_turf = get_turf(user)
	if(!my_turf.can_place_replicator_forcefield())
		if(try_start)
			to_chat(user, "<span class='notice'>This tile is already protected.</span>")
		return FALSE

	if(locate(/obj/machinery/bluespace_transponder) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the barricade.</span>")
		return FALSE

	if(locate(/obj/machinery/power/replicator_generator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the barricade.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/construct_barricade/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>SPAWNING...</span>")
	global.replicators_faction.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)

	new /obj/structure/replicator_barricade(user_replicator.loc)
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/replicator_transponder
	name = "Emit (200)"
	desc = "Create a transponder for the swarm. Transponders start consuming resources only after at least 200 have been accumulated."

	charge_type = "recharge"
	charge_max = 10 SECONDS

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_transponder"

	var/material_cost = REPLICATOR_COST_REPLICATE

/obj/effect/proc_holder/spell/no_target/replicator_transponder/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(global.replicators_faction.materials < material_cost)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough materials.</span>")
		return FALSE

	// Should fix replicating inside vents which would be buggy...
	if(!istype(user.loc, /turf/simulated/floor))
		if(try_start)
			to_chat(user, "<span class='notice'>You mustn't be inside of anything for this to work.</span>")
		return FALSE

	if(locate(/obj/machinery/bluespace_transponder) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the transponder.</span>")
		return FALSE

	if(locate(/obj/machinery/power/replicator_generator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the transponder.</span>")
		return FALSE

	for(var/bt in global.transponders)
		if(get_dist(bt, user) >= 7)
			continue
		if(try_start)
			to_chat(user, "<span class='notice'>Transponder too close to other transponders. Need at least 7 tile distance.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/replicator_transponder/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>SPAWNING...</span>")
	global.replicators_faction.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)

	new /obj/machinery/bluespace_transponder(user_replicator.loc)
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/construct_generator
	name = "Construct Generator (200)"
	desc = "Construct a generator to power transponders."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_generator"

	var/material_cost = 200

/obj/effect/proc_holder/spell/no_target/construct_generator/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(global.replicators_faction.materials < material_cost)
		if(try_start)
			to_chat(user, "<span class='warning'>Not enough materials.</span>")
		return FALSE

	if(!istype(user.loc, /turf/simulated/floor))
		if(try_start)
			to_chat(user, "<span class='notice'>You mustn't be inside of anything for this to work.</span>")
		return FALSE

	if(locate(/obj/machinery/bluespace_transponder) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the generator.</span>")
		return FALSE

	if(locate(/obj/machinery/power/replicator_generator) in user.loc)
		if(try_start)
			to_chat(user, "<span class='notice'>Need more space for the generator.</span>")
		return FALSE

	if(!(locate(/obj/structure/cable) in user.loc))
		if(try_start)
			to_chat(user, "<span class='notice'>The generator requries a cable to attach to.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/construct_generator/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>SPAWNING...</span>")
	global.replicators_faction.adjust_materials(-material_cost, adjusted_by=user_replicator.ckey)

	new /obj/machinery/power/replicator_generator(user_replicator.loc)
	playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)


/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction
	name = "Toggle Web Construction (1)"
	desc = "Toggle auto construction of the Bluespace Web."

	charge_type = "recharge"
	charge_max = 1 SECOND

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_corridor"

/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/replicator/user_replicator = user
	if(!user_replicator.auto_construct_type)
		user_replicator.auto_construct_type = /obj/structure/bluespace_corridor
		user_replicator.auto_construct_cost = 1
		to_chat(user_replicator, "<span class='notice'>You toggle web construction on.</span>")

		user_replicator.try_construct(get_turf(user_replicator))

		action.background_icon_state = "ui_corridor_on"

	else
		user_replicator.auto_construct_type = null
		user_replicator.auto_construct_cost = 0
		to_chat(user_replicator, "<span class='notice'>You toggle web construction off.</span>")

		action.background_icon_state = "ui_corridor"


/obj/effect/proc_holder/spell/no_target/transfer_to_idle
	name = "Idle Transfer"
	desc = "Transfer to an idle member of the swarm."

	charge_type = "recharge"
	charge_max = 10 SECONDS

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_transfer_idle"

/obj/effect/proc_holder/spell/no_target/transfer_to_idle/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(length(global.idle_replicators) <= 0)
		if(try_start)
			to_chat(user, "<span class='notice'>No suitable hosts found.</span>")
		return FALSE

	return ..()

/obj/effect/proc_holder/spell/no_target/transfer_to_idle/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/replicator/user_replicator = user
	to_chat(user, "<span class='notice'>TRANSFERING...</span>")
	user_replicator.transfer_control(pick(global.idle_replicators))


/obj/effect/proc_holder/spell/no_target/transfer_to_area
	name = "Area Transfer"
	desc = "Transfer to a replicator from an area."

	charge_type = "recharge"
	charge_max = 10 SECONDS

	clothes_req = FALSE

	action_icon = 'icons/mob/replicator.dmi'
	action_icon_state = "ui_transfer_area"

/obj/effect/proc_holder/spell/no_target/transfer_to_area/cast(list/targets, mob/user = usr)
	var/list/pos_areas = list()
	for(var/name in teleportlocs)
		var/area/A = teleportlocs[name]
		if(!(locate(/mob/living/simple_animal/replicator) in A))
			continue
		pos_areas[name] = teleportlocs[name]

	var/area_name = tgui_input_list(user, "Choose an area with replicators in it.", "Area Transfer", pos_areas)
	if(!area_name)
		charge_counter = charge_max
		return FALSE

	var/area/thearea = teleportlocs[area_name]

	for(var/mob/living/simple_animal/replicator/R in thearea)
		if(R.ckey)
			continue
		var/mob/living/simple_animal/replicator/user_replicator = user
		to_chat(user, "<span class='notice'>TRANSFERING...</span>")
		user_replicator.transfer_control(R)
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
	var/mob/living/simple_animal/replicator/user_replicator = user

	var/new_tag = input("Select the desired destination.", "Set Mail Tag", null) as null|anything in tagger_locations
	if(!new_tag)
		user_replicator.mail_destination = ""
		return

	to_chat(user, "<span class='notice'>You configure your internal beacon, tagging yourself for delivery to '[new_tag]'.</span>")
	user_replicator.mail_destination = new_tag

	user_replicator.try_enter_disposal_system()
