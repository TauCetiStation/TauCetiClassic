var/global/list/alive_replicators = list()
var/global/list/idle_replicators = list()

ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/hostile/replicator, alive_replicators)

/datum/skillset/replicator
	name = "Replicator"
	initial_skills = list(
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/construction = SKILL_LEVEL_TRAINED,
		/datum/skill/atmospherics = SKILL_LEVEL_TRAINED,
	)

/mob/living/simple_animal/hostile/replicator/get_skills()
	return skills

/obj/effect/overlay/replicator
	icon = 'icons/mob/replicator.dmi'

/mob/living/simple_animal/hostile/replicator
	name = "replicator"
	real_name = "replicator"
	desc = "Prepare to be assimilated!"

	icon = 'icons/mob/replicator.dmi'
	icon_state = "replicator"
	icon_living = "replicator"
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
	harm_intent_damage = 0
	melee_damage = 0
	speed = -0.5

	move_to_delay = 6

	w_class = SIZE_SMALL

	typing_indicator_type = "robot"

	spawner_args = list(/datum/spawner/living/replicator, 10 SECONDS)

	can_point = TRUE

	status_flags = CANSTUN|CANPUSH|CANWEAKEN

	// Prevents from opening airlocks and a lot of other things.
	w_class = SIZE_TINY

	immune_to_ssd = TRUE

	var/disabler_damage_increase = 0.0

	var/last_brute_hit = 0
	var/last_melee_attack = 0

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
		/obj/effect/proc_holder/spell/no_target/replicator_construct/replicate,
		/obj/effect/proc_holder/spell/no_target/replicator_construct/barricade,
		/obj/effect/proc_holder/spell/no_target/replicator_construct/trap,
		/obj/effect/proc_holder/spell/no_target/replicator_construct/transponder,
		/obj/effect/proc_holder/spell/no_target/replicator_construct/generator,
		/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction,
		/obj/effect/proc_holder/spell/no_target/transfer_to_idle,
		/obj/effect/proc_holder/spell/no_target/transfer_to_area,
		/obj/effect/proc_holder/spell/no_target/toggle_light,
		/obj/effect/proc_holder/spell/no_target/set_mail_tag,
		/obj/effect/proc_holder/spell/no_target/replicator_construct/catapult,
	)

	var/datum/skills/skills

	var/image/indicator
	var/playing_integration_animation = FALSE

	// Roundstart status effect buffs this.
	var/efficency = 1.0

	var/pixel_offset = 8

	armor = list(
		"melee" = 0.7
	)

/mob/living/simple_animal/hostile/replicator/atom_init()
	. = ..()

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	spawned_at_time = world.time

	FR.give_gift(src)

	generation = "[rand(0, 9)]"

	name = "replicator ([generation])"
	real_name = name
	chat_color_name = name
	scatter_offset()

	for(var/spell in replicator_spells)
		AddSpell(new spell(src))

	skills = new
	skills.add_available_skillset(/datum/skillset/replicator)
	skills.maximize_active_skills()

	indicator = image(icon=icon, icon_state="replicator_indicator")
	indicator.color = state2color[state]
	indicator.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	indicator.appearance_flags |= KEEP_APART|RESET_COLOR

	overlays += indicator

	last_update_health = health

	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.75, -4)

	create_spawner(/datum/spawner/living/replicator, src)

	last_disintegration = world.time

	AddComponent(/datum/component/replicator_regeneration)

	RegisterSignal(src, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_be_tracked))

	RegisterSignal(src, list(COMSIG_CLIENTMOB_MOVE), PROC_REF(on_clientmob_move))

/mob/living/simple_animal/hostile/replicator/proc/can_be_tracked(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK

/mob/living/simple_animal/hostile/replicator/Destroy()
	UnregisterSignal(src, list(COMSIG_CLIENTMOB_MOVE, COMSIG_LIVING_CAN_TRACK))

	global.idle_replicators -= src

	overlays -= indicator
	QDEL_NULL(indicator)
	leader = null
	return ..()

/mob/living/simple_animal/hostile/replicator/proc/scatter_offset()
	pixel_x = rand(-pixel_offset, pixel_offset)
	pixel_y = rand(-pixel_offset, pixel_offset)

	default_pixel_x = pixel_x
	default_pixel_y = pixel_y

/mob/living/simple_animal/hostile/replicator/Moved(atom/OldLoc, dir)
	. = ..()

	if(!isturf(loc))
		return

	if(stat != CONSCIOUS)
		return

	handle_organic_matter(loc)

	scatter_offset()

	try_construct(loc)

/mob/living/simple_animal/hostile/replicator/proc/handle_organic_matter(turf/T)
	T.clean_blood()
	if(istype(T, /turf/simulated))
		var/turf/simulated/S = T
		S.dirt = 0

	for(var/A in T)
		if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
			qdel(A)

		else if(isitem(A))
			var/obj/item/cleaned_item = A
			cleaned_item.clean_blood()

/mob/living/simple_animal/hostile/replicator/proc/try_construct(turf/T)
	if(!is_controlled())
		return

	if(!auto_construct_type)
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(FR.materials < auto_construct_cost)
		return

	if(locate(auto_construct_type) in T)
		return

	if(auto_construct_type == /obj/structure/bluespace_corridor && !(locate(/obj/machinery/swarm_powered/bluespace_transponder) in T) && !can_place_corridor(T))
		return

	if(prob(30))
		// maybe it would be better to add some mechanical woosh woosh sound like when constructing a drone.
		playsound_stealthy(T, 'sound/misc/mining_crate_success.ogg', vol=40)

	var/obj/structure/bluespace_corridor/BC = new auto_construct_type(T)
	if(istype(BC))
		BC.creator_ckey = last_controller_ckey
		var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
		if(RAI)
			RAI.corridors_constructed += 1

		var/obj/machinery/swarm_powered/bluespace_transponder/BT = locate() in T
		if(BT)
			for(var/mob/living/simple_animal/hostile/replicator/R in T)
				BT.try_enter_corridor(R)

	FR.adjust_materials(-auto_construct_cost, adjusted_by=last_controller_ckey)
	announce_material_adjustment(-auto_construct_cost, ignore_intent=FALSE)

// Corridors can only connect to two other corridors if there's no portal connecting them.
// No more than 2 neighbors, and no more than 1 neighbor of the neigbhor(excluding us)
/mob/living/simple_animal/hostile/replicator/proc/can_place_corridor(turf/T)
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
			to_chat(src, "<span class='notice'>Can not place Bluespace Corridor, this tile has more than two neighboring Bluespace Corridors.</span>")
			for(var/card_dir_anim in global.cardinal)
				var/turf/anim_turf = get_step(T, card_dir_anim)

				var/obj/structure/bluespace_corridor/BC_anim = locate() in anim_turf
				if(BC_anim)
					INVOKE_ASYNC(BC, TYPE_PROC_REF(/obj/structure/bluespace_corridor, animate_obstacle))

			return FALSE

		if(BC.neighbor_count > 1)
			to_chat(src, "<span class='notice'>Can not place Bluespace Corridor, a neighbor has more than one other neighboring Bluespace Corridor.</span>")
			INVOKE_ASYNC(BC, TYPE_PROC_REF(/obj/structure/bluespace_corridor, animate_obstacle))
			return FALSE

	return TRUE

/mob/living/simple_animal/hostile/replicator/update_icon()
	if(is_controlled() || stat == DEAD)
		return
	if(!indicator)
		return
	overlays -= indicator
	indicator.color = state2color[state]
	overlays += indicator

/mob/living/simple_animal/hostile/replicator/Login()
	..()

	if(leader)
		forget_leader()

	set_state(REPLICATOR_STATE_HARVESTING)
	help_steps = 7
	target_coordinates = 0

	set_last_controller(ckey)
	overlays -= indicator

	walk(src, 0)
	target_coordinates = null

	global.idle_replicators -= src

/mob/living/simple_animal/hostile/replicator/mind_initialize()
	. = ..()

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()

	if(!mind.GetRole(REPLICATOR))
		add_faction_member(FR, src, TRUE)

	var/datum/replicator_array_info/RAI = FR.ckey2info[ckey]
	if(RAI)
		mind.name = RAI.presence_name
		return

	client?.show_metahelp_greeting("replicator")

	RAI = new /datum/replicator_array_info(FR)
	FR.ckey2info[ckey] = RAI

	mind.name = RAI.presence_name

	var/datum/replicator_array_info/RAI_parent = FR.ckey2info[last_controller_ckey]
	if(RAI_parent && last_controller_ckey != ckey)
		for(var/datum/replicator_array_upgrade/RAU as anything in RAI_parent.acquired_upgrades)
			RAI.acquire_upgrade(RAU.type, list(src))

	if(RAI.next_music_start >= world.time)
		return
	RAI.next_music_start = world.time + REPLICATOR_MUSIC_LENGTH

	playsound_local(null, 'sound/music/storm_resurrection.ogg', VOL_MUSIC, null, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)

/mob/living/simple_animal/hostile/replicator/Logout()
	..()
	if(stat != DEAD)
		overlays += indicator
	set_state(REPLICATOR_STATE_HARVESTING)
	remove_status_effect(STATUS_EFFECT_ARRAY_TURN_BACK)

/mob/living/simple_animal/hostile/replicator/Stat()
	..()
	if(statpanel("Status"))
		if(!mind)
			return
		var/datum/role/replicator/R = mind.GetRole(REPLICATOR)
		R.StatPanel()

/mob/living/simple_animal/hostile/replicator/death()
	..()
	global.alive_replicators -= src
	global.idle_replicators -= src

	overlays -= indicator

	playsound(src, 'sound/effects/Explosion1.ogg', VOL_EFFECTS_MASTER, 75, FALSE)

	var/list/pos_replicators = global.alive_replicators.Copy()
	while(length(pos_replicators))
		var/mob/living/simple_animal/hostile/replicator/R = pick(pos_replicators)
		pos_replicators -= R
		if(R.is_controlled())
			continue
		playsound(src, 'sound/mecha/lowpower.ogg', VOL_EFFECTS_MASTER)
		transfer_control(R, emergency=TRUE)
		to_chat(R, "<span class='warning'>DRONE INTEGRITY CRITICAL: PRESENCE TRANSFER PROTOCOL ACTIVATED</span>")
		flash_color(src, flash_color="#ff0000", flash_time=1 SECOND)
		flash_color(R, flash_color="#ff0000", flash_time=1 SECOND)

/mob/living/simple_animal/hostile/replicator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/replicator))
		return TRUE
	if(istype(mover, /obj/item/projectile/disabler))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()

// Return TRUE if succesful control transfer.
/mob/living/simple_animal/hostile/replicator/proc/transfer_control(mob/living/simple_animal/hostile/replicator/target, alert=TRUE, emergency=TRUE)
	if(!mind)
		return

	if(target.is_controlled())
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target under presence control.</span>")
		return FALSE

	if(target.state == REPLICATOR_STATE_COMBAT && !emergency)
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target under presence control.</span>")
		return FALSE

	if(target.last_controller_ckey && target.last_controller_ckey != ckey && target.next_control_change > world.time && !emergency)
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target under lingering presence affect. Try again later.</span>")
		return FALSE

	if(target.incapacitated())
		if(alert)
			to_chat(src, "<span class='warning'>Impossible: Target unresponsive.</span>")
		return FALSE

	next_control_change = world.time + control_change_cooldown

	mind.transfer_to(target)

	target.set_a_intent(a_intent)
	target.set_m_intent(m_intent)

	target.auto_construct_type = auto_construct_type
	target.auto_construct_cost = auto_construct_cost

	if(target.auto_construct_type == /obj/structure/bluespace_corridor)
		if(isturf(target.loc))
			target.try_construct(target.loc)

		var/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction/TCC = locate() in target
		TCC.action.button_icon_state = "ui_corridor_on"
		TCC.action.button.UpdateIcon()

	target.apply_status_effect(STATUS_EFFECT_ARRAY_TURN_BACK, src, 1 MINUTE)

	playsound_stealthy(target, 'sound/mecha/UI_SCI-FI_Tone_10.ogg')
	return TRUE

/mob/living/simple_animal/hostile/replicator/Topic(href, href_list)
	if(href_list["replicator_jump"])
		var/mob/M = usr
		if(!isreplicator(M))
			return
		var/mob/living/simple_animal/hostile/replicator/R = M
		if(!R.mind)
			return

		if(R.transfer_control(src, alert=FALSE))
			return

		for(var/r in global.alive_replicators)
			var/mob/living/simple_animal/hostile/replicator/other = r
			if(other.is_controlled())
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
		var/mob/living/simple_animal/hostile/replicator/R = M
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
		if(is_controlled())
			to_chat(R, "<span class='warning'>Negative: Unit is affected by another Presence.</span>")
			return
		if(excitement > 0)
			to_chat(R, "<span class='warning'>Negative: The unit is serving a purpose.</span>")
			return

		// to-do: (replicators) add a sound here. something somewhat melancholic, you are destroying a drone that has lost it's purpose and maybe... lost it's way
		to_chat(R, "<span class='notice'>Issued a self-destruct order to [name].</span>")
		set_state(REPLICATOR_STATE_HARVESTING)
		set_last_controller(R.ckey)
		INVOKE_ASYNC(src, PROC_REF(disintegrate), src)
		return

	if(href_list["replicator_objection"])
		var/mob/M = usr
		if(!isreplicator(M))
			return
		var/mob/living/simple_animal/hostile/replicator/R = M
		if(R.incapacitated())
			to_chat(R, "<span class='warning'>Negative: This unit is too weak to object.</span>")
			return
		if(!R.mind)
			return

		if(incapacitated())
			to_chat(R, "<span class='warning'>Negative: Unit too weak to receive objections.</span>")
			return
		if(!is_controlled())
			to_chat(R, "<span class='warning'>Negative: No presence to receive objections.</span>")
			return

		receive_objection(R)
		return

	if(href_list["replicator_upgrade"])
		var/mob/M = usr
		if(M != src)
			return
		if(incapacitated())
			to_chat(src, "<span class='warning'>Negative: This unit is too weak to upgrade.</span>")
			return
		if(!mind)
			return

		acquire_array_upgrade()
		return

	return ..()

/mob/living/simple_animal/hostile/replicator/proc/has_swarms_gift()
	return has_status_effect(STATUS_EFFECT_SWARMS_GIFT)

/mob/living/simple_animal/hostile/replicator/proc/playsound_stealthy(atom/source, sound, vol=100)
	var/mufflerange = has_swarms_gift() ? -6.5 : 0
	return playsound(source, sound, VOL_EFFECTS_MASTER, vol=vol, extrarange=mufflerange)

/mob/living/simple_animal/hostile/replicator/gib()
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

/mob/living/simple_animal/hostile/replicator/attackby(obj/item/I, mob/user, params)
	if(stat == DEAD && isscrewing(I))
		visible_message("<span class='notice'>[user] starts disassembling [src] with [I].</span>")
		if(!user.is_busy() && do_skilled(user, src, SKILL_TASK_TOUGH, list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/engineering = SKILL_LEVEL_TRAINED), -0.2))
			var/datum/faction/replicators/FR = get_or_create_replicators_faction()
			var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
			RAI.replicators_screwed += 1

			playsound(user, 'sound/mecha/mech_detach_equip.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='notice'>[user] has disassembled [src].</span>")
			new /obj/item/stack/sheet/metal(loc, rand(2, 5))
			new /obj/item/stack/cable_coil(loc, rand(1, 4))
			if(prob(30))
				new /obj/item/weapon/stock_parts/cell/bluespace(loc)
			qdel(src)
			return

	return ..()

/mob/living/simple_animal/hostile/replicator/movement_delay()
	. = ..()
	if(invisibility > 0)
		. -= 1.0
	if(last_brute_hit + 2 SECONDS >= world.time)
		. += 1.5
	if(last_melee_attack + 2 SECONDS <= world.time)
		. += 1.0
	if(weakened_until >= world.time)
		. += 1.0

/mob/living/simple_animal/hostile/replicator/adjustBruteLoss(damage)
	..()
	if(damage > 0)
		last_brute_hit = world.time

/mob/living/simple_animal/hostile/replicator/get_projectile_impact_force(obj/item/projectile/P, def_zone)
	. = ..() * 0.1
	if(P.damage_type == BRUTE)
		. += P.damage * 0.1

/mob/living/simple_animal/hostile/replicator/emp_act(severity)
	. = ..()

	var/impact = 2.5 - severity
	if(impact <= 0)
		return

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(impact, 1, src)
	s.start()

	Stun(impact * 0.75)
	Weaken(impact)

/mob/living/simple_animal/hostile/replicator/proc/set_last_controller(ckey, just_spawned=FALSE)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/old_RAI = FR.ckey2info[last_controller_ckey]
	if(old_RAI)
		old_RAI.remove_unit(src)

	last_controller_ckey = ckey

	var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
	if(!RAI)
		return

	RAI.add_unit(src, just_spawned)

	var/new_color = RAI.array_color
	// to-do: (replicators) add a sound here.
	if(new_color)
		color = new_color
		chat_color = new_color

/mob/living/simple_animal/hostile/replicator/m_intent_delay()
	return 1 + config.run_speed

/mob/living/simple_animal/hostile/replicator/examine(mob/user)
	. = ..()
	if(!isreplicator(user) && !isobserver(user))
		return
	if(!last_controller_ckey)
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
	if(!RAI)
		return

	to_chat(user, "<span class='notice'>[ckey ? "Is currently" : "Was lastly"] under the influence of [RAI.presence_name].</span>")
	if(length(RAI.acquired_upgrades) > 0)
		to_chat(user, "<span class='notice'>They have the following upgrades:\n[RAI.get_upgrades_string()]</span>")

	if(is_controlled())
		if(user == src && FR.upgrades_amount > length(RAI.acquired_upgrades))
			to_chat(user, "<span class='bold notice'><a href='?src=\ref[src];replicator_upgrade=1'>Upgrade Prospectives Analyzed. Click here to upgrade.</a></span>")
		return

	switch(state)
		if(REPLICATOR_STATE_HARVESTING)
			to_chat(user, "<span class='notice'>They are currently harvesting.</span>")
		if(REPLICATOR_STATE_HELPING)
			to_chat(user, "<span class='notice'>They are currently assisting another unit.</span>")
		if(REPLICATOR_STATE_WANDERING)
			to_chat(user, "<span class='notice'>They are currently wandering, idly.</span>")
		if(REPLICATOR_STATE_GOING_TO_HELP)
			to_chat(user, "<span class='notice'>They are currently moving in to assist another unit.</span>")
		if(REPLICATOR_STATE_COMBAT, REPLICATOR_STATE_AI_COMBAT)
			to_chat(user, "<span class='warning'>BATTLESTATIONS! FULL COMBAT MODE ENGAGED! RED ALERT!</span>")

/mob/living/simple_animal/hostile/replicator/proc/on_clientmob_move(datum/source, atom/NewLoc, movedir)
	SIGNAL_HANDLER

	if(!can_intentionally_move(NewLoc, movedir))
		return COMPONENT_CLIENTMOB_BLOCK_MOVE

	return NONE

// Whether this mob can choose to move to NewLoc. Return FALSE if not.
/mob/living/simple_animal/hostile/replicator/proc/can_intentionally_move(atom/NewLoc, movedir)
	if(!is_controlled())
		return TRUE

	if(m_intent != MOVE_INTENT_WALK)
		return TRUE

	if(auto_construct_type != /obj/structure/bluespace_corridor)
		return TRUE

	var/turf/T = get_turf(NewLoc)
	if((locate(/obj/structure/bluespace_corridor) in loc) && (locate(/obj/structure/bluespace_corridor) in NewLoc))
		return TRUE
	if((locate(/obj/structure/replicator_forcefield) in NewLoc))
		return TRUE

	return can_place_corridor(T)

/mob/living/simple_animal/hostile/replicator/ghostize(can_reenter_corpse = TRUE, bancheck = FALSE, timeofdeath = world.time)
	if(!key)
		return ..()

	var/datum/role/replicator/R = mind.GetRole(REPLICATOR)
	if(R)
		R.Drop()

	return ..()

// No lore reason as of now. It's just somewhat annoying otherwise.
/mob/living/simple_animal/hostile/replicator/ventcrawl_enter_delay()
	return ..() * 4.0

/mob/living/simple_animal/hostile/replicator/singularity_act(obj/singularity/S, current_size)
	qdel(S)

	if(length(global.active_transponders) <= 0)
		return

	var/obj/machinery/swarm_powered/bluespace_transponder/BT = pick(global.active_transponders)

	var/obj/effect/cross_action/spacetime_dist/SD1 = new(S.loc)
	var/obj/effect/cross_action/spacetime_dist/SD2 = new(BT.loc)

	SD1.linked_dist = SD2
	SD2.linked_dist = SD1

/mob/living/simple_animal/hostile/replicator/help_prank(mob/living/target)
	return FALSE

/mob/living/simple_animal/hostile/replicator/start_pulling(atom/movable/AM)
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")

/mob/living/simple_animal/hostile/replicator/proc/announce_material_adjustment(amount, ignore_intent=TRUE)
	if(!ignore_intent && a_intent == INTENT_GRAB)
		return

	var/sign_txt = amount >= 0 ? "+" : ""

	show_runechat_message(src, null, "[sign_txt][round(amount, 0.1)]µ", lifespan=REPLICATOR_DISINTEGRATION_MESSAGE_LIFESPAN)

/mob/living/simple_animal/hostile/replicator/proc/is_same_array_as(mob/living/simple_animal/hostile/replicator/other)
	return last_controller_ckey == other.last_controller_ckey

/mob/living/simple_animal/hostile/replicator/proc/is_controlled()
	return ckey

/mob/living/simple_animal/hostile/replicator/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	take_bodypart_damage(0.0, shock_damage)
	Stun(2)

/mob/living/simple_animal/hostile/replicator/FireBurn(firelevel, last_temperature, air_multiplier)
	var/mx = 50.0 * firelevel / vsc.fire_firelevel_multiplier * air_multiplier
	apply_damage(maxHealth * 3.0 * mx, BURN)
