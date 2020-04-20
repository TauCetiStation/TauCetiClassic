/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0

	var/sweep_step = 4

/obj/item/weapon/mop/atom_init()
	create_reagents(5)
	. = ..()
	mop_list += src

/obj/item/weapon/mop/Destroy()
	mop_list -= src
	return ..()

/obj/item/weapon/mop/CtrlClickAction(atom/target, mob/user)
	mop_push(target, user)
	return TRUE

/obj/item/weapon/mop/CtrlShiftClickAction(atom/target, mob/user)
	mop_pull(target, user)
	return TRUE

/obj/item/weapon/mop/AltClickAction(atom/target, mob/user)
	if(istype(target, /obj/structure/stool/bed/chair/janitorialcart))
		return FALSE // So we can still put our mop in.

	var/turf/T = get_turf(target)
	var/direction = get_dir(get_turf(src), T)
	var/list/turfs = list(turn(direction, 45), direction, turn(direction, -45))
	sweep(turfs, user, 8)
	return TRUE

/obj/item/weapon/mop/attack_self(mob/user)
	if(user.next_move > world.time)
		return
	if(user.incapacitated())
		return

	var/rot_dir = 1
	if(user.dir == SOUTH || user.dir == WEST) // South-west rotate anti-clockwise.
		rot_dir = -1

	var/list/turfs = list(user.dir, turn(user.dir, rot_dir * 45), turn(user.dir, rot_dir * 90), turn(user.dir, rot_dir * 135), turn(user.dir, rot_dir * 180), turn(user.dir, rot_dir * 225), turn(user.dir, rot_dir * 270), turn(user.dir, rot_dir * 315), user.dir)

	var/saved_sweep_step = sweep_step
	sweep_step *= 0.5
	sweep(turfs, user, 8)
	sweep_step = saved_sweep_step

/obj/item/weapon/mop/proc/push_on_chair(obj/structure/stool/bed/chair/C, mob/user, movementdirection)
	set waitfor = FALSE

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

/obj/item/weapon/mop/proc/mop_push(atom/target, mob/user)
	var/s_time = sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/src_turf = get_turf(src)
	var/turf/T_target = get_turf(target)
	var/turf/T = get_step(src_turf, get_dir(src_turf, T_target))

	for(var/obj/item/I in T)
		if(I == target)
			continue
		if(I.anchored)
			continue
		if(I.w_class <= ITEM_SIZE_NORMAL)
			var/obj/item/weapon/storage/bag/trash/TR = user.get_inactive_hand()
			if(istype(TR) && TR.can_be_inserted(I))
				TR.handle_item_insertion(I, prevent_warning = TRUE)
			else
				step_to(I, T_target)
	user.do_attack_animation(T)

	if(istype(get_turf(src), /turf/simulated) && istype(user.buckled, /obj/structure/stool/bed/chair) && !user.buckled.anchored)
		var/obj/structure/stool/bed/chair/buckled_to = user.buckled
		if(!buckled_to.flipped)
			var/direction = turn(get_dir(src_turf, T_target), 180)
			push_on_chair(user.buckled, user, direction)
			return

	if(T.Adjacent(target))
		if(!has_gravity(src) && !istype(target, /turf/space)) // A little cheat.
			step_away(user, T_target)
		else if(istype(target, /atom/movable))
			var/atom/movable/AM = target
			if(!AM.anchored)
				step_away(target, get_turf(user))

/obj/item/weapon/mop/proc/mop_pull(atom/target, mob/user)
	var/s_time = sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/src_turf = get_turf(src)
	var/turf/T_target = get_turf(target)
	var/turf/T = get_step(src_turf, get_dir(src_turf, T_target))

	for(var/obj/item/I in T)
		if(I == target)
			continue
		if(I.anchored)
			continue
		if(I.w_class <= ITEM_SIZE_NORMAL)
			var/obj/item/weapon/storage/bag/trash/TR = user.get_inactive_hand()
			if(istype(TR) && TR.can_be_inserted(I))
				TR.handle_item_insertion(I, prevent_warning = TRUE)
			else
				step_to(I, src_turf)
	user.do_attack_animation(T)

	if(T.Adjacent(target))
		if(!has_gravity(src) && !istype(target, /turf/space))
			step_to(user, T_target)
		else if(istype(target, /atom/movable))
			var/atom/movable/AM = target
			if(!AM.anchored)
				step_to(target, get_turf(user))

/obj/item/weapon/mop/proc/clean(turf/simulated/T, amount)
	if(reagents.has_reagent("water", amount))
		T.clean_blood()
		T.dirt = max(0, T.dirt - amount * 20) // #define MAGICAL_CLEANING_CONSTANT 20
		for(var/obj/effect/O in T)
			if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
				qdel(O)
	reagents.reaction(T, TOUCH, amount)
	if(T.reagents)
		reagents.trans_to(T, amount / 3)
	else
		reagents.remove_any(amount / 3)

/obj/item/weapon/mop/proc/sweep(list/directions, mob/living/user, amount)
	var/s_time = sweep_step * directions.len
	user.SetNextMove(s_time)

	var/turf/start = get_step(src, directions[1])

	user.do_attack_animation(start)
	var/obj/effect/effect/mop_image = new /obj/effect/effect(start)
	mop_image.glide_size = DELAY2GLIDESIZE(sweep_step)

	mop_image.appearance = appearance

	var/i = 0 // So we begin with one.
	for(var/dir_ in directions)
		var/turf/current_turf = get_step(src, dir_)
		i++
		INVOKE_ASYNC(src, .proc/move_mop_image, mop_image, current_turf, sweep_step)
		if(user.is_busy() || !do_after(user, sweep_step, target = current_turf, can_move = TRUE, progress = FALSE))
			break

		user.face_atom(current_turf)
		mop_image.forceMove(current_turf)
		var/turf_clear = TRUE
		var/list/to_check = list()
		to_check += current_turf.contents
		to_check += current_turf
		// Get out of the way, fellows!
		for(var/atom/A in to_check)
			if(A.density)
				to_chat(user, "<span class='warning'>Your [src] has hit [A]! There's not enough space for broad sweeps here!</span>")
				var/resolved = A.attackby(src, user, list())
				if(!resolved && src)
					afterattack(A, user, TRUE, list()) // 1 indicates adjacency
				turf_clear = FALSE
				break
			if(istype(A, /obj/item))
				var/obj/item/I = A
				if(I.anchored)
					continue
				if(I.w_class <= ITEM_SIZE_NORMAL)
					var/obj/item/weapon/storage/bag/trash/TR = user.get_inactive_hand()
					if(istype(TR) && TR.can_be_inserted(I))
						TR.handle_item_insertion(I, prevent_warning = TRUE)
					else if(i + 1 <= directions.len)
						step_to(I, get_step(src, directions[i + 1]))

		if(turf_clear)
			clean(current_turf, amount / directions.len)
		else
			if(user.buckled)
				user.buckled.user_unbuckle_mob(user)
			// You hit a wall!
			user.apply_effect(3, STUN, 0)
			user.apply_effect(3, WEAKEN, 0)
			user.apply_effect(6, STUTTER, 0)
			shake_camera(user, 1, 1)
			// here be thud sound
			break
	QDEL_IN(mop_image, sweep_step)

/obj/item/weapon/mop/proc/move_mop_image(obj/effect/effect/mop_image, turf/target, delay)
	sleep(delay)
	mop_image.forceMove(target)

/obj/item/weapon/mop/afterattack(atom/A, mob/living/user, proximity)
	if(!proximity)
		return
	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return
		if(user.is_busy(A))
			return

		INVOKE_ASYNC(user, /atom/movable.proc/do_attack_animation, A)
		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")

		if(do_after(user, sweep_step SECONDS, target = A))
			if(A)
				clean(get_turf(A), 10)
			to_chat(user, "<span class='notice'>You have finished mopping!</span>")

/obj/item/weapon/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	icon_state = "advmop"
	item_state = "advmop"
	force = 6.0
	throwforce = 10.0
	throw_range = 10.0
	sweep_step = 2

/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/kitchen/utensil/fork))
		user.SetNextMove(CLICK_CD_INTERACT)
		return
	return ..()
