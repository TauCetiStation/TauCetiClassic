/obj/item/projectile/disabler
	name = "bolt"
	icon_state = "bluelaser"
	light_color = "#0000ff"
	//light_power = 2
	//light_range = 2
	damage = 3
	damage_type = BURN
	agony = 10
	step_delay = 2
	dispersion = 1
	impact_force = 1
	pass_flags = PASSTABLE | PASSGLASS


/mob/living/simple_animal/replicator/UnarmedAttack(atom/A)
	if(isliving(A) && !isreplicator(A) && a_intent == INTENT_HARM)
		var/mob/living/L = A
		do_attack_animation(L)
		visible_message("<span class='warning'>[src] attacks [A]!</span>")
		playsound(L, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)
		L.apply_effects(0, 0, 0, 0, 1, 1, 0, 30, 0)
		SetNextMove(CLICK_CD_MELEE)
		L.set_lastattacker_info(src)
		L.log_combat(src, "replicator-attacked (INTENT: [uppertext(a_intent)]) (CONTROLLER: [last_controller_ckey])")
		scatter_offset()
		return

	if(a_intent == INTENT_GRAB)
		INVOKE_ASYNC(src, .proc/disintegrate_turf, get_turf(A))
		return

	if(istype(A, /obj/structure/replicator_forcefield) && auto_construct_type == /obj/structure/bluespace_corridor)
		try_construct(get_turf(A))
		return

	if(istype(A, /turf))
		INVOKE_ASYNC(src, .proc/disintegrate, A)
		return

	if(istype(A, /obj))
		INVOKE_ASYNC(src, .proc/disintegrate, A)
		return

	if(istype(A, /mob/living/simple_animal/replicator))
		var/mob/living/simple_animal/replicator/R = A
		if(!R.ckey || R == src)
			INVOKE_ASYNC(src, .proc/disintegrate, A)
		// repair
		return

/mob/living/simple_animal/replicator/RangedAttack(atom/A, params)
	// Adjacent() checks make this work in an unintuitive way otherwise.
	if(get_dist(src, A) <= 1 && a_intent == INTENT_GRAB)
		INVOKE_ASYNC(src, .proc/disintegrate_turf, get_turf(A))
		return

	if(a_intent == INTENT_HARM)
		SetNextMove(CLICK_CD_MELEE)
		playsound(src, 'sound/weapons/guns/gunpulse_taser2.ogg', VOL_EFFECTS_MASTER)
		var/obj/item/projectile/disabler/D = new(loc)
		D.pixel_x += rand(-1, 1)
		D.pixel_y += rand(-1, 1)
		D.Fire(A, src, params)
		scatter_offset()

		newtonian_move(get_dir(A, src))

/mob/living/simple_animal/replicator/CtrlClickOn(atom/A)
	if(istype(A, /mob/living/simple_animal/replicator))
		var/mob/living/simple_animal/replicator/S = A
		if(!S.ckey)
			transfer_control(A)
			return


/obj/item/mine/replicator
	name = "mine"
	desc = "Huh."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "trap"
	layer = 3
	anchored = TRUE

	var/next_activation = 0

/obj/item/mine/replicator/try_trigger(atom/movable/AM)
	if(isreplicator(AM))
		return
	if(istype(AM, /obj/item/projectile/disabler))
		return
	if(!anchored)
		return

	if(!iscarbon(AM) && !issilicon(AM) && !istype(AM, /obj/mecha))
		return

	AM.visible_message("<span class='danger'>[AM] steps on [src]!</span>")
	trigger_act(AM)

/obj/item/mine/replicator/atom_init()
	. = ..()
	name = "mine ([rand(0, 999)])"

/obj/item/mine/replicator/proc/do_audiovisual_effects(atom/movable/AM)
	playsound(src, 'sound/misc/mining_reward_0.ogg', VOL_EFFECTS_MASTER)

	var/image/I = image('icons/mob/replicator.dmi', "dismantle")
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.plane = AM.plane
	I.layer = AM.layer + 1.0
	I.loc = AM

	flick_overlay_view(I, AM, 12)

	audible_message("<b>[src]</b> <i>buzzes.</i>", "You see a light flicker.", hearing_distance = 7, ignored_mobs = observer_list)

/obj/item/mine/replicator/trigger_act(atom/movable/AM)
	if(next_activation > world.time)
		return
	next_activation = world.time + 40
	addtimer(CALLBACK(src, .proc/rearm), 40)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()

	if(istype(AM, /obj/mecha))
		var/obj/mecha/M = AM

		do_audiovisual_effects(M)

		M.emp_act(1)

		var/area/A = get_area(src)
		global.replicators_faction.drone_message(src, "A mine has been triggered in [A.name].", transfer=TRUE)
		return

	if(isliving(AM))
		var/mob/living/L = AM

		do_audiovisual_effects(L)

		var/stepped_by = pick(BP_R_LEG, BP_L_LEG)
		L.electrocute_act(15, src, siemens_coeff = 1.0, def_zone = stepped_by) // electrocute act does a message.
		L.Stun(1)

		var/area/A = get_area(src)
		global.replicators_faction.drone_message(src, "A mine has been triggered in [A.name].", transfer=TRUE)

/obj/item/mine/replicator/disarm()
	qdel(src)

/obj/item/mine/replicator/proc/rearm()
	// to-do: sound
	update_icon()

/obj/item/mine/replicator/update_icon()
	if(next_activation < world.time)
		icon_state = "[initial(icon_state)]armed"
		alpha = 45
	else
		icon_state = initial(icon_state)
		alpha = 255

/obj/item/mine/replicator/Topic(href, href_list)
	if(href_list["replicator_jump"])
		var/mob/M = usr
		if(!isreplicator(M))
			return
		var/mob/living/simple_animal/replicator/R = M
		if(R.incapacitated())
			return
		if(!R.mind)
			return

		for(var/r in global.alive_replicators)
			var/mob/living/simple_animal/replicator/other = r
			if(other.ckey)
				continue
			if(get_dist(src, other) > 7)
				continue
			if(!R.transfer_control(other, alert=FALSE))
				continue

		to_chat(src, "<span class='notice'>Other presence is already attending this situation.</span>")
		return

	return ..()
