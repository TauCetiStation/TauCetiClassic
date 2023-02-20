var/global/list/replicators = list()

ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/replicator, replicators)

/datum/skillset/replicator
	name = "Replicator"
	initial_skills = list(
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/construction = SKILL_LEVEL_TRAINED,
		/datum/skill/atmospherics = SKILL_LEVEL_TRAINED,
	)

/mob/living/simple_animal/replicator/get_skills()
	return skills

/obj/effect/overlay/replicator
	icon = 'icons/mob/replicator.dmi'

/mob/living/simple_animal/replicator
	name = "replicator"
	real_name = "replicator"
	desc = "Prepare to be assimilated!"

	icon = 'icons/mob/replicator.dmi'
	icon_state = "replicator"
	icon_dead = "replicator-deactivated"

	speak_emote = list("beeps")
	emote_hear = list("beeps", "boops")
	response_help  = "nudges"
	response_disarm = "jumps at"
	response_harm = "hits"

	default_emotes = list(
		/datum/emote/list,
		/datum/emote/clickable/help_replicator,
	)

	a_intent = INTENT_HELP
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	universal_speak = FALSE
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	faction = "replicator"

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE

	pass_flags = PASSTABLE
	ventcrawler = TRUE
	can_enter_vent_with = list(
		/obj/effect/proc_holder/spell,
	)

	maxHealth = 25
	health = 25
	response_harm = "hits"
	harm_intent_damage = 2
	melee_damage = 0
	speed = -1

	w_class = SIZE_TINY

	var/generation = ""

	var/next_attacked_alert = 0
	var/attacked_alert_cooldown = 10 SECONDS

	var/last_update_health = 0

	// This item will be built on each move above a forcefield tile.
	var/auto_construct_type = null
	var/auto_construct_cost = 0

	var/spawned_at_time = 0

	var/mail_destination = ""

	var/last_controller_ckey = null
	var/next_control_change = 0
	var/control_change_cooldown = 10 SECONDS

	var/disintegrating = FALSE

	var/list/replicator_spells = list(
		/obj/effect/proc_holder/spell/no_target/replicator_replicate,
		/obj/effect/proc_holder/spell/no_target/replicator_transponder,
		/obj/effect/proc_holder/spell/no_target/construct_generator,
		/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction,
		/obj/effect/proc_holder/spell/no_target/transfer_to_idle,
		/obj/effect/proc_holder/spell/no_target/transfer_to_area,
		/obj/effect/proc_holder/spell/no_target/toggle_light,
		/obj/effect/proc_holder/spell/no_target/set_mail_tag,
	)

	var/datum/skills/skills

	var/image/indicator
	var/image/integration_overlay

	var/list/state2color = list(
		REPLICATOR_STATE_HARVESTING = "#CCFF00",
		REPLICATOR_STATE_HELPING = "#00FFCC",
		REPLICATOR_STATE_WANDERING = "#CC00FF",
		REPLICATOR_STATE_GOING_TO_HELP = "#00CCFF",
	)

	// Roundstart status effect buffs this.
	var/efficency = 1.0

/mob/living/simple_animal/replicator/atom_init()
	. = ..()

	global.replicators_faction = create_uniq_faction(/datum/faction/replicators)
	spawned_at_time = world.time

	global.replicators_faction.give_gift(src)

	generation = rand(0, 9)

	name = "replicator ([generation])"
	real_name = name
	pixel_x = rand(-6, 6)
	pixel_y = rand(-6, 6)

	for(var/spell in replicator_spells)
		AddSpell(new spell(src))

	skills = new
	skills.add_available_skillset(/datum/skillset/replicator)
	skills.maximize_active_skills()

	indicator = image(icon=icon, icon_state="replicator_indicator")
	indicator.color = state2color[state]
	indicator.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	overlays += indicator

	last_update_health = health

	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.75, -3)

/mob/living/simple_animal/replicator/Destroy()
	overlays -= indicator
	QDEL_NULL(indicator)
	overlays -= integration_overlay
	QDEL_NULL(integration_overlay)
	return ..()

/mob/living/simple_animal/replicator/Moved(atom/OldLoc, dir)
	. = ..()

	if(!auto_construct_type)
		return

	if(global.replicators_faction.materials < auto_construct_cost)
		return

	var/turf/my_turf = get_turf(src)
	if(loc != my_turf)
		return

	if(!istype(my_turf, /turf/simulated/floor/plating/airless/catwalk/forcefield))
		return

	if(locate(auto_construct_type) in my_turf)
		return

	// Corridors can only connect to two other corridors if there's no portal connecting them.
	if(auto_construct_type == /obj/structure/bluespace_corridor && !(locate(/obj/machinery/bluespace_transponder) in my_turf))
		var/neighbor_count = 0
		for(var/t in RANGE_TURFS(1, my_turf))
			var/turf/T = t
			if(locate(auto_construct_type) in T)
				neighbor_count += 1
				// Elegant solution to forks.
				if(neighbor_count >= 3)
					return
		return

	new auto_construct_type(my_turf)
	global.replicators_faction.adjust_materials(-auto_construct_cost, adjusted_by=last_controller_ckey)

/mob/living/simple_animal/replicator/update_icon()
	if(ckey)
		return
	overlays -= indicator
	indicator.color = state2color[state]
	overlays += indicator

/mob/living/simple_animal/replicator/Login()
	..()

	set_state(REPLICATOR_STATE_HARVESTING)
	help_steps = 7
	target_coordinates = 0

	last_controller_ckey = ckey
	overlays -= indicator

/mob/living/simple_animal/replicator/mind_initialize()
	. = ..()
	var/datum/role/replicator/R = mind.GetRole(REPLICATOR)
	if(R)
		return

	add_faction_member(global.replicators_faction, src, TRUE)

/mob/living/simple_animal/replicator/Logout()
	..()
	overlays += indicator

/mob/living/simple_animal/replicator/Stat()
	..()
	if(statpanel("Status"))
		stat("Materials:", "[global.replicators_faction.materials] ([global.replicators_faction.last_second_materials_change])")
		stat("Drone Amount:", "[length(global.replicators)]/[global.replicators_faction.bandwidth]")
		stat("Bandwidth Upgrade:", "[global.replicators_faction.materials_consumed]/[global.replicators_faction.consumed_materials_until_upgrade]")
		stat("Presence Count:", length(global.replicators_faction.members))
		//stat("Swarm's Goodwill:", global.replicators_faction.swarms_goodwill[ckey])

/mob/living/simple_animal/replicator/death()
	..()
	global.replicators -= src

	playsound(src, 'sound/effects/Explosion1.ogg', VOL_EFFECTS_MASTER, 75, FALSE)

	var/list/pos_replicators = list() + global.replicators
	while(length(pos_replicators))
		var/mob/living/simple_animal/construct/C = pick(pos_replicators)
		pos_replicators -= C

		if(!C.ckey)
			to_chat(C, "<span class='warning'>DRONE INTEGRITY CRITICAL: PRESENCE TRANSFER PROTOCOL ACTIVATED</span>")
			playsound(src, 'sound/mecha/lowpower.ogg', VOL_EFFECTS_MASTER)
			// add red flashing to screen that would be super cool
			transfer_control(C)

/mob/living/simple_animal/replicator/UnarmedAttack(atom/A)
	if(a_intent == INTENT_HARM)
		INVOKE_ASYNC(src, .proc/disintegrate_turf, get_turf(A))
		return

	if(istype(A, /turf))
		INVOKE_ASYNC(src, .proc/disintegrate, A)
		return

	if(istype(A, /obj))
		INVOKE_ASYNC(src, .proc/disintegrate, A)
		return

	if(istype(A, /mob/living/simple_animal/replicator))
		var/mob/living/simple_animal/replicator/R = A
		if(R.stat == DEAD)
			INVOKE_ASYNC(src, .proc/disintegrate, R)
		// repair
		return

/mob/living/simple_animal/replicator/RangedAttack(atom/A)
	// Adjacent() checks make this work in an unintuitive way otherwise.
	if(get_dist(src, A) <= 1 && a_intent == INTENT_HARM)
		INVOKE_ASYNC(src, .proc/disintegrate_turf, get_turf(A))
		return

/mob/living/simple_animal/replicator/ShiftClickOn(atom/A)

/mob/living/simple_animal/replicator/CtrlClickOn(atom/A)
	if(istype(A, /mob/living/simple_animal/replicator))
		var/mob/living/simple_animal/replicator/S = A
		if(!S.ckey)
			transfer_control(A)
			return

/mob/living/simple_animal/replicator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	// if istype replicator disabler projectile
	return ..()

/mob/living/simple_animal/replicator/proc/disintegrate_turf(turf/T)
	var/target_x = T.x
	var/target_y = T.y
	var/target_z = T.z

	var/start_loc = loc

	while(!is_busy() && do_after(src, 1, target=src, progress=FALSE))
		if(start_loc != loc)
			return

		var/atom/disintegratable = get_disintegratable_from(locate(target_x, target_y, target_z))
		if(!disintegratable)
			return
		face_atom(disintegratable)
		disintegrate(disintegratable)

/mob/living/simple_animal/replicator/proc/get_disintegratable_from(turf/T)
	for(var/a in T.contents)
		var/atom/A = a
		if(is_auto_disintegratable(A))
			return A

	if(istype(T, /turf/simulated/floor/plating/airless/catwalk/forcefield))
		return null
	if(!is_auto_disintegratable(T))
		return null

	return T

// Return TRUE if disintegrated something.
/mob/living/simple_animal/replicator/proc/disintegrate(atom/A)
	if(is_busy())
		return FALSE
	if(disintegrating)
		return FALSE
	if(A.is_disintegrating)
		return FALSE

	if(A.flags & NODECONSTRUCT)
		to_chat(src, "<span class='warning'>Object Does Not Disintegrate.</span>")
		return FALSE

	if((locate(/mob/living) in A) && !isturf(A))
		to_chat(src, "<span class='warning'>Can Not Deconstruct: May Harm Organis</span>")
		return FALSE

	var/material_amount = A.get_replicator_material_amount()
	if(material_amount < 0)
		return FALSE

	disintegrating = TRUE
	A.is_disintegrating = TRUE

	var/obj/effect/overlay/replicator/D = new(get_turf(A))
	D.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	D.plane = A.plane
	D.layer = A.layer + 0.1
	D.icon_state = "disintegrate_static"

	// Disintegration begin sound
	playsound(A, 'sound/machines/cyclotron.ogg', VOL_EFFECTS_MASTER)

	if(!do_skilled(src, A, A.get_unit_disintegration_time() * material_amount / efficency, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), -0.2))
		qdel(D)
		disintegrating = FALSE
		A.is_disintegrating = FALSE
		return FALSE

	// Woooshoop sound.
	playsound(src, 'sound/mecha/UI_SCI-FI_Compute_01_Wet.ogg', VOL_EFFECTS_MASTER)

	var/obj/effect/overlay/replicator/target_appearance = new(get_turf(A))
	target_appearance.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	target_appearance.plane = A.plane
	target_appearance.layer = A.layer + 0.09
	target_appearance.appearance = A

	var/matrix/M = matrix(A.transform)

	// make the item we're targetting waddle?
	if(!A.replicator_act(src))
		qdel(D)
		qdel(target_appearance)
		disintegrating = FALSE
		A.is_disintegrating = FALSE
		return FALSE

	D.icon = 'icons/mob/replicator.dmi'
	D.icon_state = "disintegrate"

	M.Scale(0.1, 0.1)
	M = turn(M, 180)

	var/matrix/M2 = matrix(M)

	animate(target_appearance, transform=M, time=8)
	animate(D, transform=M2, time=8)

	QDEL_IN(D, 8)
	QDEL_IN(target_appearance, 8)

	//integrate_animation()

	global.replicators_faction.adjust_materials(material_amount, adjusted_by=last_controller_ckey)
	disintegrating = FALSE
	A.is_disintegrating = FALSE
	return TRUE

/*
	CURSED: I can't get the overlay to display on the mob for some reason. Please send help.

/mob/living/simple_animal/replicator/proc/integrate_animation()
	if(integration_overlay)
		return
	integration_overlay = image(icon=icon, icon_state="integrate")
	integration_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	integration_overlay.icon = icon
	integration_overlay.icon_state = "integrate"
	//integration_overlay.plane = plane
	//integration_overlay.layer = layer
	integration_overlay.loc = src

	overlays += integration_overlay

	to_chat(world, "ADDING INTEGRATE OVERLAY [world.time] with framework!")

	addtimer(CALLBACK(src, .proc/remove_integrate_overlay), 10)

/mob/living/simple_animal/replicator/proc/remove_integrate_overlay()
	to_chat(world, "REMOVING INTEGRATE OVERLAY [world.time] with framework!")
	overlays -= integration_overlay
	QDEL_NULL(integration_overlay)
*/

// Return TRUE if succesful control transfer.
/mob/living/simple_animal/replicator/proc/transfer_control(mob/living/simple_animal/replicator/target, alert=TRUE)
	if(target.ckey)
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target under presence control.</span>")
		return FALSE

	if(target.last_controller_ckey != ckey && next_control_change > world.time)
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target under lingering presence affect. Try again later.</span>")
		return FALSE

	if(target.incapacitated())
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target unresponsive.</span>")
		return FALSE

	next_control_change = world.time + control_change_cooldown

	mind.transfer_to(target)
	playsound(target, 'sound/mecha/UI_SCI-FI_Tone_10.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/mob/living/simple_animal/replicator/say(message)
	global.replicators_faction.announce_swarm(global.replicators_faction.get_presence_name(ckey), ckey, message)
