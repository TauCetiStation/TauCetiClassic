var/global/list/alive_replicators = list()
var/global/list/idle_replicators = list()

ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/replicator, alive_replicators)

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
		/datum/emote/robot/beep,
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

	typing_indicator_type = "robot"

	spawner_args = list(/datum/spawner/living/replicator, 2 MINUTES)

	can_point = TRUE

	// How many drones are under direct control.
	var/controlling_drones = 0

	var/sacrifice_powering = FALSE

	var/generation = ""

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
		/obj/effect/proc_holder/spell/no_target/spawn_trap,
		/obj/effect/proc_holder/spell/no_target/replicator_transponder,
		/obj/effect/proc_holder/spell/no_target/construct_generator,
		/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction,
		/obj/effect/proc_holder/spell/no_target/transfer_to_idle,
		/obj/effect/proc_holder/spell/no_target/transfer_to_area,
		/obj/effect/proc_holder/spell/no_target/toggle_light,
		/obj/effect/proc_holder/spell/no_target/set_mail_tag,
		/obj/effect/proc_holder/spell/no_target/construct_catapult,
	)

	var/datum/skills/skills

	var/image/indicator
	var/playing_integration_animation = FALSE

	// Roundstart status effect buffs this.
	var/efficency = 1.0

	var/pixel_offset = 8

/mob/living/simple_animal/replicator/atom_init()
	. = ..()

	global.replicators_faction = create_uniq_faction(/datum/faction/replicators)
	spawned_at_time = world.time

	global.replicators_faction.give_gift(src)

	generation = "[rand(0, 9)]"

	name = "replicator ([generation])"
	real_name = name
	scatter_offset()

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

	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.75, -4)

	create_spawner(/datum/spawner/living/replicator, src)

/mob/living/simple_animal/replicator/Destroy()
	global.idle_replicators -= src

	overlays -= indicator
	QDEL_NULL(indicator)
	leader = null
	return ..()

/mob/living/simple_animal/replicator/proc/scatter_offset()
	pixel_x = rand(-pixel_offset, pixel_offset)
	pixel_y = rand(-pixel_offset, pixel_offset)

/mob/living/simple_animal/replicator/Moved(atom/OldLoc, dir)
	. = ..()

	if(!isturf(loc))
		return

	scatter_offset()

	try_construct(loc)

/mob/living/simple_animal/replicator/proc/try_construct(turf/T)
	if(!ckey)
		return

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

	if(prob(30))
		// maybe it would be better to add some mechanical woosh woosh sound like when constructing a drone.
		playsound_stealthy(T, 'sound/misc/mining_crate_success.ogg', VOL_EFFECTS_MASTER, vol=40)

	new auto_construct_type(T)
	global.replicators_faction.adjust_materials(-auto_construct_cost, adjusted_by=last_controller_ckey)

/mob/living/simple_animal/replicator/update_icon()
	if(ckey || stat == DEAD)
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
	if(!R)
		R = add_faction_member(global.replicators_faction, src, TRUE)
		if(R.next_music_start < world.time)
			playsound_local(null, 'sound/music/storm_resurrection.ogg', VOL_MUSIC, null, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)
			R.next_music_start = world.time + 5 MINUTES

	// It would make more sense lore-wise if it was tied to the swarms gift, but oh well...
	/*
	if(has_swarms_gift() && R.next_music_start < world.time)
		// Scale volume with amount of drones?
		playsound_local(null, 'sound/music/storm_resurrection.ogg', VOL_MUSIC, null, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)
		R.next_music_start = world.time + 5 MINUTES
	*/

/mob/living/simple_animal/replicator/Logout()
	..()
	if(stat != DEAD)
		overlays += indicator
	set_state(REPLICATOR_STATE_HARVESTING)

/mob/living/simple_animal/replicator/Stat()
	..()
	if(statpanel("Status"))
		stat("Materials:", "[round(global.replicators_faction.materials)] ([round(global.replicators_faction.last_second_materials_change)])")
		stat("Drone Amount:", "[length(global.alive_replicators)]/[global.replicators_faction.bandwidth]")
		if(length(global.active_transponders) > 0)
			stat("Bandwidth Upgrade:", "[round(global.replicators_faction.materials_consumed)]/[global.replicators_faction.consumed_materials_until_upgrade]")
		if(length(global.replicator_generators) > 0)
			stat("Energy Reserves:", "[round(global.replicators_faction.energy)]/[round(length(global.replicator_generators) * REPLICATOR_GENERATOR_POWER_GENERATION)]")

		if(length(global.area2free_forcefield_nodes) > 0)
			var/node_string = ""
			var/first = TRUE
			for(var/area_name in global.area2free_forcefield_nodes)
				var/node_count = global.area2free_forcefield_nodes[area_name]
				if(!first)
					node_string += ", "
				first = FALSE
				node_string += "[area_name] ([node_count])"
			stat("Unclaimed Nodes:", node_string)

		if(length(global.bluespace_catapults) > 0)
			stat("Catapult Location:", get_area(global.bluespace_catapults[1]))

/mob/living/simple_animal/replicator/death()
	..()
	global.alive_replicators -= src

	overlays -= indicator

	playsound(src, 'sound/effects/Explosion1.ogg', VOL_EFFECTS_MASTER, 75, FALSE)

	var/list/pos_replicators = list() + global.alive_replicators
	while(length(pos_replicators))
		var/mob/living/simple_animal/construct/C = pick(pos_replicators)
		pos_replicators -= C
		if(C.ckey)
			continue
		playsound(src, 'sound/mecha/lowpower.ogg', VOL_EFFECTS_MASTER)
		transfer_control(C)
		to_chat(C, "<span class='warning'>DRONE INTEGRITY CRITICAL: PRESENCE TRANSFER PROTOCOL ACTIVATED</span>")
		flash_color(src, flash_color="#ff0000", flash_time=1 SECOND)
		flash_color(C, flash_color="#ff0000", flash_time=1 SECOND)

/mob/living/simple_animal/replicator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover, /obj/item/projectile/disabler))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()

// Return TRUE if succesful control transfer.
/mob/living/simple_animal/replicator/proc/transfer_control(mob/living/simple_animal/replicator/target, alert=TRUE)
	if(!mind)
		return

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

	target.a_intent = a_intent
	mind.transfer_to(target)
	playsound_stealthy(target, 'sound/mecha/UI_SCI-FI_Tone_10.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/mob/living/simple_animal/replicator/Topic(href, href_list)
	if(href_list["replicator_jump"])
		var/mob/M = usr
		if(!isreplicator(M))
			return
		var/mob/living/simple_animal/replicator/R = M
		if(!R.mind)
			return

		if(R.transfer_control(src, alert=FALSE))
			return

		for(var/r in global.alive_replicators)
			var/mob/living/simple_animal/replicator/other = r
			if(other.ckey)
				continue
			if(get_dist(src, other) > 7)
				continue
			if(!R.transfer_control(other, alert=FALSE))
				continue

		to_chat(R, "<span class='notice'>Other presence is already attending this situation.</span>")
		return

	if(href_list["replicator_kill"])
		var/mob/M = usr
		if(!isreplicator(M))
			return
		var/mob/living/simple_animal/replicator/R = M
		if(R.incapacitated())
			to_chat(R, "<span class='warning'>Negative: Unit too weak to issue a self-disintegrate order.</span>")
			return
		if(!R.mind)
			return

		if(disintegrating)
			to_chat(R, "<span class='warning'>Negative: The unit is serving a purpose.</span>")
			return
		if(incapacitated())
			to_chat(R, "<span class='warning'>Negative: Unit too weak to self-disintegrate.</span>")
			return
		if(ckey)
			to_chat(R, "<span class='warning'>Negative: Unit is affected by another Presence.</span>")
			return
		if(excitement > 0)
			to_chat(R, "<span class='warning'>Negative: The unit is serving a purpose.</span>")
			return

		// TO-DO: sound
		to_chat(R, "<span class='notice'>Issued a self-destruct order to [name].</span>")
		set_state(REPLICATOR_STATE_HARVESTING)
		last_controller_ckey = R.ckey
		INVOKE_ASYNC(src, .proc/disintegrate, src)
		return

	return ..()

/mob/living/simple_animal/replicator/proc/has_swarms_gift()
	return has_status_effect(STATUS_EFFECT_SWARMS_GIFT)

/mob/living/simple_animal/replicator/proc/playsound_stealthy(atom/source, sound, volume_channel, vol=100)
	var/mufflerange = has_swarms_gift() ? -5 : 0
	return playsound(source, sound, volume_channel, vol=vol, extrarange=mufflerange)

/mob/living/simple_animal/replicator/proc/try_spawn_node(turf/T)
	if(!prob(5))
		return FALSE

	if(global.replicators_faction.nodes_to_spawn <= 0)
		return FALSE

	if(locate(/obj/structure/forcefield_node) in T)
		return FALSE

	for(var/fn in global.forcefield_nodes)
		if(get_dist(T, fn) < 5)
			return FALSE

	var/obj/structure/forcefield_node/FN = new(T)
	FN.color = pick("#A8DFF0", "#F0A8DF", "#DFF0A8")

	var/area/A = get_area(T)
	emote("beep")
	global.replicators_faction.drone_message(src, "Node unveiled at [A.name].", transfer=TRUE)

/mob/living/simple_animal/replicator/gib()
	death(TRUE)
	var/atom/movable/overlay/animation = null
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

//	flick("gibbed-r", animation)
	robogibs(loc)

	dead_mob_list -= src
	QDEL_IN(src, 15)
	QDEL_IN(animation, 15)

/mob/living/simple_animal/replicator/attackby(obj/item/I, mob/user, params)
	if(stat == DEAD && isscrewing(I))
		visible_message("<span class='notice'>[user] starts disassembling [src] with [I].</span>")
		if(!user.is_busy() && do_skilled(user, src, SKILL_TASK_AVERAGE, list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/engineering = SKILL_LEVEL_TRAINED), -0.2))
			playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='notice'>[user] has disassembled [src].</span>")
			new /obj/item/stack/sheet/metal(loc, 3)
			new /obj/item/stack/cable_coil(loc, 2)
			new /obj/item/weapon/stock_parts/cell/bluespace(loc)
			qdel(src)
			return

	return ..()
