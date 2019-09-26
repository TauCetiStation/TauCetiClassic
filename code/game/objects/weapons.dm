/obj/effect/effect/weapon_sweep
	name = "sweep"

/obj/effect/effect/weapon_sweep/atom_init(mapload, obj/item/weapon/sweep_item)
	. = ..()
	name = "sweeping [sweep_item]"
	glide_size = DELAY2GLIDESIZE(sweep_item.sweep_step)

	appearance = sweep_item.appearance

/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'

	var/interupt_on_sweep_hit_types = list(/atom) // By default we interupt on any hit.

	var/can_push = FALSE
	var/hit_on_harm_push = FALSE
	var/can_push_on_chair = FALSE
	var/can_pull = FALSE
	var/hit_on_harm_pull = FALSE

	var/can_sweep = FALSE
	var/can_spin = FALSE
	var/spin_on_middleclick = FALSE
	var/sweep_step = 4

/obj/item/weapon/proc/can_push()
	return can_push

/obj/item/weapon/proc/can_pull()
	return can_pull

/obj/item/weapon/proc/can_sweep()
	return can_sweep

/obj/item/weapon/proc/can_spin()
	return can_spin

/obj/item/weapon/proc/on_sweep_move(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, mob/living/user)
	user.face_atom(current_turf)

/obj/item/weapon/proc/move_sweep_image(turf/target, obj/effect/effect/weapon_sweep/sweep_image)
	sleep(sweep_step)
	sweep_image.forceMove(target)

/obj/item/weapon/proc/can_sweep_hit(atom/A, mob/living/user)
	return A.density || istype(A, /obj/effect/effect/weapon_sweep)

/*
 * Return TRUE to call on_sweep_interupt, and stun the player or whatever.
 */
/obj/item/weapon/proc/on_sweep_hit(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/A, mob/living/user)
	var/is_stunned = is_type_in_list(A, interupt_on_sweep_hit_types)
	if(is_stunned)
		to_chat(user, "<span class='warning'>Your [src] has hit [A]! There's not enough space for broad sweeps here!</span>")

	if(user.a_intent == I_HURT && is_type_in_list(A, list(/obj/machinery/disposal, /obj/structure/table, /obj/structure/rack)))
		/*
		A very weird snowflakey thing but very crucial to keeping this fun.
		If we're on HARM and we hit anything that should drop our item from the hands,
		we just ignore the click to it.
		*/
		return FALSE

	var/resolved = A.attackby(src, user, list())
	if(!resolved && src)
		afterattack(A, user, TRUE, list()) // 1 indicates adjacency

	return is_stunned

/obj/item/weapon/proc/on_sweep_to_check(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/A, mob/living/user, list/directions, i)
	return

/obj/item/weapon/proc/on_sweep_finish(turf/current_turf, mob/living/user)
	return

/obj/item/weapon/proc/on_sweep_interupt(turf/current_turf, mob/living/user)
	if(user.buckled)
		user.buckled.user_unbuckle_mob(user)
	// You hit a wall!
	user.apply_effect(3, STUN, 0)
	user.apply_effect(3, WEAKEN, 0)
	user.apply_effect(6, STUTTER, 0)
	shake_camera(user, 1, 1)
	// here be thud sound

/obj/item/weapon/proc/sweep_continue_check(mob/living/user, sweep_step, turf/current_turf)
	if(!can_sweep() && !can_spin())
		return FALSE
	if(user.is_busy() || !do_after(user, sweep_step, target = current_turf, can_move = TRUE, progress = FALSE))
		return FALSE
	return TRUE

/*
 * Returns TRUE if you hit something.
 */
/obj/item/weapon/proc/sweep(list/directions, mob/living/user, sweep_delay)
	var/turf/start = get_step(src, directions[1])

	user.do_attack_animation(start)
	var/obj/effect/effect/weapon_sweep/sweep_image = new /obj/effect/effect/weapon_sweep(start, src)

	var/i = 0 // So we begin with one.
	for(var/dir_ in directions)
		var/turf/current_turf = get_step(src, dir_)
		i++

		INVOKE_ASYNC(src, /obj/item/weapon.proc/move_sweep_image, current_turf, sweep_image)
		if(!sweep_continue_check(user, sweep_delay, current_turf))
			break

		on_sweep_move(current_turf, sweep_image, user)

		var/list/to_check = list()
		to_check += current_turf.contents
		to_check += current_turf
		to_check -= sweep_image
		to_check.Remove(user)
		// Get out of the way, fellows!
		for(var/atom/A in to_check)
			if(can_sweep_hit(A, user))
				. = on_sweep_hit(current_turf, sweep_image, A, user)
				break
			on_sweep_to_check(current_turf, sweep_image, A, user, directions, i)
			user.SetNextMove(sweep_delay + 1)

		if(!.)
			on_sweep_finish(current_turf, user)
		else
			on_sweep_interupt(current_turf, user)
			break

	QDEL_IN(sweep_image, sweep_delay)

/obj/item/weapon/proc/on_sweep_push(atom/target, turf/T, mob/user)
	return

/obj/item/weapon/proc/on_sweep_push_success(atom/target, mob/user)
	var/turf/T_target = get_turf(target)

	if(hit_on_harm_push && user.a_intent != I_HELP)
		var/resolved = target.attackby(src, user, list())
		if(!resolved && src)
			afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(src) && !istype(target, /turf/space))
		step_away(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			step_away(target, get_turf(src))

/obj/item/weapon/proc/sweep_push(atom/target, mob/user)
	var/s_time = sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/src_turf = get_turf(src)
	var/turf/T_target = get_turf(target)
	var/turf/T = get_step(src_turf, get_dir(src_turf, T_target))

	on_sweep_push(T_target, T, user)
	user.do_attack_animation(T)

	if(can_push_on_chair && istype(get_turf(src), /turf/simulated) && istype(user.buckled, /obj/structure/stool/bed/chair) && !user.buckled.anchored)
		var/obj/structure/stool/bed/chair/buckled_to = user.buckled
		if(!buckled_to.flipped)
			var/direction = turn(get_dir(src_turf, T_target), 180)
			INVOKE_ASYNC(src, /obj/item/weapon.proc/push_on_chair, user.buckled, user, direction)
			return

	if(T.Adjacent(target))
		on_sweep_push_success(target, user)

/obj/item/weapon/proc/on_sweep_pull(atom/target, turf/T, mob/user)
	return

/obj/item/weapon/proc/on_sweep_pull_success(atom/target, mob/user)
	var/turf/T_target = get_turf(target)

	if(hit_on_harm_pull && user.a_intent != I_HELP)
		var/resolved = target.attackby(src, user, list())
		if(!resolved && src)
			afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(src) && !istype(target, /turf/space))
		step_to(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			step_to(target, get_turf(src))

/obj/item/weapon/proc/sweep_pull(atom/target, mob/user)
	var/s_time = sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/src_turf = get_turf(src)
	var/turf/T_target = get_turf(target)
	var/turf/T = get_step(src_turf, get_dir(src_turf, T_target))

	on_sweep_pull(T_target, T, user)
	user.do_attack_animation(T)

	if(T.Adjacent(target))
		on_sweep_pull_success(target, user)

/obj/item/weapon/proc/push_on_chair(obj/structure/stool/bed/chair/C, mob/user, movementdirection)
	if(C)
		C.propelled = 4
	step(C, movementdirection)
	sleep(1)
	step(C, movementdirection)
	if(C)
		C.propelled = 3
	sleep(1)
	step(C, movementdirection)
	sleep(1)
	step(C, movementdirection)
	if(C)
		C.propelled = 2
	sleep(2)
	step(C, movementdirection)
	if(C)
		C.propelled = 1
	sleep(2)
	step(C, movementdirection)
	if(C)
		C.propelled = 0
	sleep(3)
	step(C, movementdirection)
	sleep(3)
	step(C, movementdirection)
	sleep(3)
	step(C, movementdirection)

/obj/item/weapon/CtrlClickAction(atom/target, mob/user)
	if(!can_push())
		return ..()

	sweep_push(target, user)
	return TRUE

/obj/item/weapon/CtrlShiftClickAction(atom/target, mob/user)
	if(!can_pull())
		return ..()

	sweep_pull(target, user)
	return TRUE

/obj/item/weapon/AltClickAction(atom/target, mob/user)
	if(!can_sweep())
		return ..()

	var/turf/T = get_turf(target)
	var/direction = get_dir(get_turf(src), T)
	var/list/turfs = list(turn(direction, 45), direction, turn(direction, -45))
	sweep(turfs, user, sweep_step)
	return TRUE

/obj/item/weapon/proc/sweep_spin(mob/user)
	var/rot_dir = 1
	if(user.dir == SOUTH || user.dir == WEST) // South-west rotate anti-clockwise.
		rot_dir = -1

	var/list/turfs = list(user.dir, turn(user.dir, rot_dir * 45), turn(user.dir, rot_dir * 90), turn(user.dir, rot_dir * 135), turn(user.dir, rot_dir * 180), turn(user.dir, rot_dir * 225), turn(user.dir, rot_dir * 270), turn(user.dir, rot_dir * 315), user.dir)

	var/saved_sweep_step = sweep_step
	sweep_step *= 0.5
	sweep(turfs, user, sweep_step)
	sweep_step = saved_sweep_step

/obj/item/weapon/MiddleClickAction(atom/target, mob/user)
	if(!spin_on_middleclick)
		return ..()

	if(can_spin())
		sweep_spin(user)
		return TRUE
	return FALSE

/obj/item/weapon/attack_self(mob/user)
	if(spin_on_middleclick)
		..()
		return

	if(can_spin())
		sweep_spin(user)
		return
	..()

/obj/item/weapon/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(. && can_push())
		var/obj/item/weapon/shield/S
		if(def_zone == BP_L_ARM && istype(M.l_hand, /obj/item/weapon/shield))
			S = M.l_hand
		else if(def_zone == BP_R_ARM && istype(M.r_hand, /obj/item/weapon/shield))
			S = M.r_hand

		if(S && prob(S.Get_shield_chance()))
			user.visible_message("<span class='warning'>[user] knocks down [M] with \a [src]!</span>", "<span class='warning'>You knock down [M] with \a [src]!</span>")
			if(M.buckled)
				M.buckled.user_unbuckle_mob(M)

			M.apply_effect(3, STUN, 0)
			M.apply_effect(3, WEAKEN, 0)
			M.apply_effect(6, STUTTER, 0)
			shake_camera(M, 1, 1)

/obj/item/weapon/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day due to it's ease of lodging itself into victim's body parts"
	icon_state = "throwingstar"
	item_state = "eshield0"
	force = 2
	throwforce = 20
	throw_speed = 6
	w_class = ITEM_SIZE_SMALL
	sharp = 1
	edge = 1
	can_embed = 1
	materials = list(MAT_METAL=500, MAT_GLASS=500)
