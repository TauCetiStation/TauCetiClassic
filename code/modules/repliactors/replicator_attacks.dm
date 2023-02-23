/obj/item/projectile/disabler
	name = "bolt"
	icon_state = "bluelaser"
	light_color = "#0000ff"
	//light_power = 2
	//light_range = 2
	damage = 3
	damage_type = BURN
	agony = 20
	step_delay = 2
	dispersion = 1
	impact_force = 1


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

/obj/item/mine/replicator/trigger_act(atom/movable/AM)
	if(next_activation > world.time)
		return
	next_activation = world.time + 12
	addtimer(CALLBACK(src, .proc/rearm), 12)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()

	if(!isliving(AM))
		return

	playsound(src, 'sound/misc/mining_reward_0.ogg', VOL_EFFECTS_MASTER)

	var/mob/living/L = AM

	var/image/I = image('icons/mob/replicator.dmi', "dismantle")
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.plane = L.plane
	I.layer = L.layer + 0.09
	I.loc = L

	flick_overlay_view(I, L, 12)

	var/stepped_by = pick(BP_R_LEG, BP_L_LEG)
	L.electrocute_act(30, src, siemens_coeff = 1.0, def_zone = stepped_by) // electrocute act does a message.
	L.Stun(2)

	var/area/A = get_area(src)
	global.replicators_faction.drone_message(src, "A mine has been triggered in [A.name].")

/obj/item/mine/replicator/proc/rearm()
	update_icon()

/obj/item/mine/replicator/update_icon()
	if(next_activation < world.time)
		icon_state = "[initial(icon_state)]armed"
		alpha = 45
	else
		icon_state = initial(icon_state)
		alpha = 255
