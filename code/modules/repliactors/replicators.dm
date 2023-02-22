var/global/list/replicators = list()
var/global/list/idle_replicators = list()

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
	icon_dead = "replicator_unactivated"

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

	maxHealth = 60
	health = 60
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
		/obj/effect/proc_holder/spell/no_target/construct_barricade,
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
	var/playing_integration_animation = FALSE

	// Roundstart status effect buffs this.
	var/efficency = 1.0

/mob/living/simple_animal/replicator/atom_init()
	. = ..()

	global.replicators_faction = create_uniq_faction(/datum/faction/replicators)
	spawned_at_time = world.time

	global.replicators_faction.give_gift(src)

	generation = "[rand(0, 9)]"

	name = "replicator ([generation])"
	real_name = name
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

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

	create_spawner(/datum/spawner/living/replicator, src)

/mob/living/simple_animal/replicator/Destroy()
	overlays -= indicator
	QDEL_NULL(indicator)
	leader = null
	return ..()

/mob/living/simple_animal/replicator/Moved(atom/OldLoc, dir)
	. = ..()

	if(!isturf(loc))
		return

	try_construct(loc)

/mob/living/simple_animal/replicator/proc/try_construct(turf/T)
	if(!auto_construct_type)
		return

	if(global.replicators_faction.materials < auto_construct_cost)
		return

	//if(!istype(my_turf, /turf/simulated/floor/plating/airless/catwalk/forcefield))
	//	return

	if(locate(auto_construct_type) in T)
		return

	// Corridors can only connect to two other corridors if there's no portal connecting them.
	// No more than 2 neighbors, and no more than 1 neighbor of the neigbhor(excluding us)
	if(auto_construct_type == /obj/structure/bluespace_corridor && !(locate(/obj/machinery/swarm_powered/bluespace_transponder) in T))
		var/neighbor_count = 0
		for(var/card_dir in global.cardinal)
			var/turf/pos_neighbor = get_step(T, card_dir)

			if(locate(/obj/machinery/swarm_powered/bluespace_transponder) in pos_neighbor)
				continue

			var/obj/structure/bluespace_corridor/BC = locate(auto_construct_type) in pos_neighbor
			if(!BC)
				continue
			neighbor_count += 1
			if(neighbor_count > 2)
				return

			if(BC.neighbor_count > 1)
				return

	new auto_construct_type(T)
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

	global.idle_replicators -= src

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

/mob/living/simple_animal/replicator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover, /obj/item/projectile/disabler))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
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
	playsound_stealthy(A, 'sound/machines/cyclotron.ogg', VOL_EFFECTS_MASTER)

	if(!do_skilled(src, A, A.get_unit_disintegration_time() * material_amount / efficency, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), -0.2))
		qdel(D)
		disintegrating = FALSE
		A.is_disintegrating = FALSE
		return FALSE

	playsound_stealthy(src, 'sound/mecha/UI_SCI-FI_Compute_01_Wet.ogg', VOL_EFFECTS_MASTER)

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
	doesn't look neat :(
/mob/living/simple_animal/replicator/proc/integrate_animation()
	if(playing_integration_animation)
		return
	playing_integration_animation = TRUE

	var/image/I = image(icon=icon, icon_state="integrate")
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.layer = layer + 0.1
	I.plane = plane
	I.loc = src

	flick_overlay_view(I, src, 5)

	VARSET_IN(src, playing_integration_animation, FALSE, 5)
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
	playsound_stealthy(target, 'sound/mecha/UI_SCI-FI_Tone_10.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/mob/living/simple_animal/replicator/say(message)
	if(stat != CONSCIOUS)
		return

	message = sanitize(message)

	if(!message)
		return

	if(message[1] == "*")
		return emote(copytext(message, 2))

	message = add_period(capitalize(message))

	global.replicators_faction.announce_swarm(global.replicators_faction.get_presence_name(ckey), ckey, message, announcer=src)

/mob/living/simple_animal/replicator/Topic(href, href_list)
	if(incapacitated())
		return ..()
	if(!mind)
		return ..()

	if(href_list["replicator_jump"])
		var/mob/living/simple_animal/replicator/target = locate(href_list["replicator_jump"])
		if(!istype(target))
			return

		if(transfer_control(target, alert=FALSE))
			return

		for(var/r in global.replicators)
			var/mob/living/simple_animal/replicator/R = r
			if(R.ckey)
				continue
			if(get_dist(src, R) > 7)
				continue
			if(!transfer_control(R, alert=FALSE))
				continue

		to_chat(src, "<span class='notice'>Other presence is already attending this situation.</span>")
		return

	if(href_list["replicator_kill"])
		var/mob/living/simple_animal/replicator/target = locate(href_list["replicator_kill"])
		if(!istype(target))
			return

		if(target.incapacitated())
			return

		if(target.excitement > 0)
			to_chat(src, "<span class='warning'>Negative: The unit is serving a purpose.</span>")
			return

		// TO-DO: sound
		target.last_controller_ckey = ckey
		INVOKE_ASYNC(target, .proc/disintegrate, target)
		return

/mob/living/simple_animal/replicator/proc/playsound_stealthy(atom/source, sound)
	var/mufflerange = has_swarms_gift() ? -5 : 0
	var/mufflefalloff = has_swarms_gift() ? 0.75 : null
	var/mufflevolume = has_swarms_gift() ? 75 : 100
	return playsound(source, sound, VOL_EFFECTS_MASTER, volume=mufflevolume, falloff=mufflefalloff, extrarange=mufflerange)

/mob/living/simple_animal/replicator/proc/has_swarms_gift()
	return has_status_effect(STATUS_EFFECT_SWARMS_GIFT)
