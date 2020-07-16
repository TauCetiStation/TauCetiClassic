// The appearance of a swiping weapon.
// TODO: Add some sort of trail to indicate "movement"?
// (?) Allow to be catched by hand(at the cost of being hit by it, or perhaps intergrate with combos).
// (?) Pass pull_act, ex_act, emp_act, and etc to the swiped item.
/obj/effect/effect/weapon_sweep
	name = "sweep"
	layer = INFRONT_MOB_LAYER

	var/sweep_delay = 0
	var/list/dirs_to_move
	var/next_dir = 1

/obj/effect/effect/weapon_sweep/atom_init(mapload, obj/item/weapon/sweep_item, list/dirs_to_move, sweep_delay)
	. = ..()
	name = "sweeping [sweep_item]"
	glide_size = DELAY2GLIDESIZE(sweep_delay)

	appearance = sweep_item.appearance

	src.sweep_delay = sweep_delay
	src.dirs_to_move = dirs_to_move



// Is used to set all the required params for swiping component.
// Instantinate before adding component, no need to save anywhere.
/datum/swipe_component_builder
	// Which items will cause a stun when hit.
	var/list/interupt_on_sweep_hit_types = list(/atom)

	// Whether you can push stuff with this weapon.
	var/can_push = FALSE

	// Whether you can pull stuff with this weapon.
	var/can_pull = FALSE

	// Whether you can sweep at all using this weapon.
	var/can_sweep = FALSE
	// Whether you can spin-sweep 1 tile around you with this weapon. can_sweep is not required to be able to spin.
	var/can_spin = FALSE

	 // A callback that allows to check for additional conditions before pushing.
	var/datum/callback/can_push_call
	// A callback that allows to check for additional conditions before pulling.
	var/datum/callback/can_pull_call
	// A callback that allows to check for additional conditions before sweeping.
	var/datum/callback/can_sweep_call
	// A callback that allows to check for additional conditions before spinning.
	var/datum/callback/can_spin_call

	// A callback that allows to give more than one object with it's directions for a sweep. Is used for double energy swords.
	var/datum/callback/on_get_sweep_objects

	// A callback that replaces sweep_move.
	var/datum/callback/on_sweep_move
	// A callback that replaces can_sweep_hit.
	var/datum/callback/on_can_sweep_hit
	// A callback that replaces sweep_hit.
	var/datum/callback/on_sweep_hit
	// A callback that replaces sweep_to_check.
	var/datum/callback/on_sweep_to_check
	// A callback that replaces sweep_finish.
	var/datum/callback/on_sweep_finish
	// A callback that replaces sweep_interupt.
	var/datum/callback/on_sweep_interupt

	// A callback that completely replaces the spin logic. Is used in double energy swords.
	var/datum/callback/on_spin

	// A callback that replaces sweep_continue_check.
	var/datum/callback/on_sweep_continue_check

	// A callback that replaces sweep_push.
	var/datum/callback/on_sweep_push
	// A callback that replaces sweep_push_success.
	var/datum/callback/on_sweep_push_success

	// A callback that replaces sweep_pull.
	var/datum/callback/on_sweep_pull
	// A callback that replaces sweep_pull_success.
	var/datum/callback/on_sweep_pull_success



#define SWIPING_TIP "Is swipable."

/datum/mechanic_tip/swiping
	tip_name = SWIPING_TIP

/datum/mechanic_tip/swiping/New(datum/component/swiping/S)
	var/pos_moves = ""

	if(S.can_push)
		pos_moves += "It is capable of pushing. To push, either ctrl-click the thing you want to push, or swipe your mouse in the direction away from you."
		pos_moves += " Pushing while buckled to a movable object will thrust you in the direction opposite to the push."
		if(S.can_push_call)
			pos_moves += " Requires certain criteria to be met to be able to push."

	if(S.can_pull)
		if(pos_moves != "")
			pos_moves += "\n"
		pos_moves += "It is capable of pulling. To pull, either ctrl-shift-click the thing you want to pull, or swipe your mouse over the thing towards yourself."
		if(S.can_pull_call)
			pos_moves += " Requires certain criteria to be met to be able to pull."

	if(S.can_sweep)
		if(pos_moves != "")
			pos_moves += "\n"
		pos_moves += "It is capable of sweeping. To sweep, either alt-click the thing you want to sweep at, or swipe your mouse across the tiles you want to sweep."
		if(S.can_sweep_call)
			pos_moves += " Requires certain criteria to be met to be able to sweep."

	if(S.can_spin)
		if(pos_moves != "")
			pos_moves += "\n"
		pos_moves += "It is capable of spinning. To spin, either use the object in hands, or middle-click, or swipe diagonally across yourself."
		if(S.can_spin_call)
			pos_moves += " Requires certain criteria to be met to be able to spin."

	description = "This object appears to be swipable. You can perform swipes either via mouse moves, or click modifiers.\n[pos_moves]"

/datum/component/swiping
	var/list/interupt_on_sweep_hit_types = list(/atom)

	var/can_push = FALSE

	var/can_pull = FALSE

	var/can_sweep = FALSE
	var/can_spin = FALSE

	var/datum/callback/on_get_sweep_objects

	var/datum/callback/can_push_call
	var/datum/callback/can_pull_call
	var/datum/callback/can_sweep_call
	var/datum/callback/can_spin_call

	var/datum/callback/on_sweep_move
	var/datum/callback/on_can_sweep_hit
	var/datum/callback/on_sweep_hit
	var/datum/callback/on_sweep_to_check
	var/datum/callback/on_sweep_finish
	var/datum/callback/on_sweep_interupt

	var/datum/callback/on_spin

	var/datum/callback/on_sweep_continue_check

	var/datum/callback/on_sweep_push
	var/datum/callback/on_sweep_push_success

	var/datum/callback/on_sweep_pull
	var/datum/callback/on_sweep_pull_success

/datum/component/swiping/Initialize(datum/swipe_component_builder/SCB)
	if(!istype(parent, /obj/item/weapon))
		return COMPONENT_INCOMPATIBLE

	interupt_on_sweep_hit_types = SCB.interupt_on_sweep_hit_types

	if(SCB.can_push)
		can_push = TRUE

		can_push_call = SCB.can_push_call
		on_sweep_push = SCB.on_sweep_push
		on_sweep_push_success = SCB.on_sweep_push_success

		RegisterSignal(parent, list(COMSIG_ITEM_CTRLCLICKWITH), .proc/try_sweep_push)
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK), .proc/try_push_attack)

	if(SCB.can_pull)
		can_pull = TRUE

		can_pull_call = SCB.can_pull_call
		on_sweep_pull = SCB.on_sweep_pull
		on_sweep_pull_success = SCB.on_sweep_pull_success

		RegisterSignal(parent, list(COMSIG_ITEM_CTRLSHIFTCLICKWITH), .proc/try_sweep_pull)

	on_sweep_move = SCB.on_sweep_move
	on_can_sweep_hit = SCB.on_can_sweep_hit
	on_sweep_hit = SCB.on_sweep_hit
	on_sweep_to_check = SCB.on_sweep_to_check
	on_sweep_finish = SCB.on_sweep_finish
	on_sweep_interupt = SCB.on_sweep_interupt
	on_sweep_continue_check = SCB.on_sweep_continue_check
	on_get_sweep_objects = SCB.on_get_sweep_objects

	if(SCB.can_sweep)
		can_sweep = TRUE
		can_sweep_call = SCB.can_sweep_call
		RegisterSignal(parent, list(COMSIG_ITEM_ALTCLICKWITH), .proc/sweep_facing)

	if(SCB.can_spin)
		can_spin = TRUE
		can_spin_call = SCB.can_spin_call
		on_spin = SCB.on_spin
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/sweep_spin)
		RegisterSignal(parent, list(COMSIG_ITEM_MIDDLECLICKWITH), .proc/sweep_spin_click)

	RegisterSignal(parent, list(COMSIG_ITEM_MOUSEDROP_ONTO), .proc/sweep_mousedrop)

	var/datum/mechanic_tip/swiping/swipe_tip = new(src)
	parent.AddComponent(/datum/component/mechanic_desc, list(swipe_tip))

/datum/component/swiping/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(SWIPING_TIP))
	return ..()

/datum/component/swiping/proc/get_sweep_objects(turf/start, obj/item/I, mob/user, list/directions, sweep_delay)
	if(on_get_sweep_objects)
		return on_get_sweep_objects.Invoke(start, I, user, directions, sweep_delay)

	var/list/sweep_objects = list()
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions, sweep_delay)
	return sweep_objects

/datum/component/swiping/proc/move_sweep_image(turf/target, obj/effect/effect/weapon_sweep/sweep_image)
	sleep(sweep_image.sweep_delay)
	sweep_image.forceMove(target)

/*
	Procs related to pushing.
	Pushing means "swiping" in general direction of click, and if possible - moving the target away from user.
	Some items allow to go WOOSH when pushing while being on chair-like structure that can move.
	Some items allow to hit if your intent is I_HURT when pushing.
*/
/datum/component/swiping/proc/push_on_chair(obj/structure/stool/bed/chair/C, mob/user, movementdirection)
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

/datum/component/swiping/proc/sweep_push(atom/target, turf/T, mob/user)
	if(on_sweep_push)
		on_sweep_push.Invoke(target, T, user)

/datum/component/swiping/proc/sweep_push_success(atom/target, mob/user)
	if(on_sweep_push_success)
		on_sweep_push_success.Invoke(target, user)
		return

	var/turf/T_target = get_turf(target)

	if(user.a_intent != INTENT_HELP)
		var/resolved = target.attackby(parent, user, list())
		if(!resolved && parent)
			var/obj/item/I = parent
			I.afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(parent) && !istype(target, /turf/space))
		step_away(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			step_away(target, get_turf(parent))

/datum/component/swiping/proc/try_sweep_push(datum/source, atom/target, mob/user)
	if(!isturf(target) && !isturf(target.loc))
		return NONE

	if(can_push_call)
		if(!can_push_call.Invoke(target, user))
			return NONE

	var/obj/item/weapon/W = parent

	var/s_time = W.sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/W_turf = get_turf(W)
	var/turf/T_target = get_turf(target)

	var/obj/effect/effect/weapon_sweep/WS = new(W_turf, W, list(), W.sweep_step)
	WS.invisibility = 101
	WS.pass_flags = W.pass_flags

	step(WS, get_dir(W_turf, T_target))

	var/turf/T = get_turf(WS)

	sweep_push(target, T, user)

	user.face_atom(T)
	user.do_attack_animation(T)

	if(istype(get_turf(W), /turf/simulated) && istype(user.buckled, /obj/structure/stool/bed/chair) && !user.buckled.anchored && user.buckled != target)
		var/obj/structure/stool/bed/chair/buckled_to = user.buckled
		if(!buckled_to.flipped)
			var/direction = get_dir(T_target, W_turf)
			INVOKE_ASYNC(src, .proc/push_on_chair, user.buckled, user, direction)
			qdel(WS)
			return COMSIG_ITEM_CANCEL_CLICKWITH

	if(WS.Adjacent(target))
		sweep_push_success(target, user)

	qdel(WS)

	return COMSIG_ITEM_CANCEL_CLICKWITH

// Pushing items have a bonus of knocking people with shields over if hit into the right place(the arm with she shield).
/datum/component/swiping/proc/try_push_attack(datum/source, mob/living/target ,mob/living/user, def_zone)
	// Bootleg jousting code? ~Luduk.
	var/obj/item/weapon/shield/S
	if(def_zone == BP_L_ARM && istype(target.l_hand, /obj/item/weapon/shield))
		S = target.l_hand
	else if(def_zone == BP_R_ARM && istype(target.r_hand, /obj/item/weapon/shield))
		S = target.r_hand

	if(S && prob(S.Get_shield_chance()))
		user.visible_message("<span class='warning'>[user] knocks [target] down with \a [src]!</span>", "<span class='warning'>You knock [target] down with \a [src]!</span>")
		if(target.buckled)
			target.buckled.user_unbuckle_mob(target)

		target.apply_effect(2, STUN, 0)
		target.apply_effect(2, WEAKEN, 0)
		target.apply_effect(4, STUTTER, 0)
		shake_camera(target, 1, 1)

/*
	Procs related to pulling
	Pulling means "swiping" in general direction of click, and if possible - moving the target towards the user.
	Some items allow to hit if your intent is I_HURT when pulling.
*/
/datum/component/swiping/proc/sweep_pull(atom/target, turf/T, mob/user)
	if(on_sweep_pull)
		on_sweep_pull.Invoke(target, T, user)

/datum/component/swiping/proc/sweep_pull_success(atom/target, mob/user)
	if(on_sweep_pull_success)
		on_sweep_pull_success.Invoke(target, user)
		return

	var/turf/T_target = get_turf(target)

	if(user.a_intent != INTENT_HELP)
		var/resolved = target.attackby(parent, user, list())
		if(!resolved && parent)
			var/obj/item/I = parent
			I.afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(parent) && !istype(target, /turf/space))
		step_to(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			step_to(target, get_turf(parent))

/datum/component/swiping/proc/try_sweep_pull(datum/source, atom/target, mob/user)
	if(!isturf(target) && !isturf(target.loc))
		return NONE

	if(can_pull_call)
		if(!can_pull_call.Invoke(target, user))
			return NONE

	var/obj/item/weapon/W = parent

	var/s_time = W.sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/W_turf = get_turf(W)
	var/turf/T_target = get_turf(target)

	var/obj/effect/effect/weapon_sweep/WS = new(W_turf, W, list(), W.sweep_step)
	WS.invisibility = 101
	WS.pass_flags = W.pass_flags

	step(WS, get_dir(W_turf, T_target))

	var/turf/T = get_turf(WS)

	sweep_pull(target, T, user)

	user.face_atom(T)
	user.do_attack_animation(T)

	if(WS.Adjacent(target))
		sweep_pull_success(target, user)

	qdel(WS)

	return COMSIG_ITEM_CANCEL_CLICKWITH

/*
	Procs related to sweeping(in general)
	Sweeping is moving a *representation* of an object smoothly
	across some tiles.
	When, as user sweep, they encounter an obstacle - if they hit them, they get stunned.

	TODO: make pull and push rely on sweep too?
*/
// Whether user can continue sweeping at all.
/datum/component/swiping/proc/sweep_continue_check(mob/user, sweep_delay)
	if(on_sweep_continue_check)
		return on_sweep_continue_check.Invoke(user, sweep_delay)

	if(can_spin_call)
		if(!can_spin_call.Invoke(user))
			return FALSE
	else if(can_sweep_call)
		if(!can_sweep_call.Invoke(user))
			return FALSE

	if(user.get_active_hand() != parent)
		return FALSE

	if(user.is_busy() || !do_after(user, sweep_delay, target = parent, can_move = TRUE, progress = FALSE))
		return FALSE
	return TRUE

// A proc called each new tile we're swiping across, before all the possible checks.
/datum/component/swiping/proc/sweep_move(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, mob/user)
	user.face_atom(current_turf)

	if(on_sweep_move)
		on_sweep_move.Invoke(current_turf, sweep_image, user)
		return

// A proc that checks whether the sweep will hit target.
/datum/component/swiping/proc/can_sweep_hit(atom/target, mob/user)
	if(on_can_sweep_hit)
		return on_can_sweep_hit.Invoke(target, user)
	return target.density || istype(target, /obj/effect/effect/weapon_sweep)

// What happens when we *hit* an atom.
/datum/component/swiping/proc/sweep_hit(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/target, mob/user)
	if(on_sweep_hit)
		return on_sweep_hit.Invoke(current_turf, sweep_image, target, user)

	if(user.a_intent == INTENT_HARM && is_type_in_list(target, list(/obj/machinery/disposal, /obj/structure/table, /obj/structure/rack)))
		/*
		A very weird snowflakey thing but very crucial to keeping this fun.
		If we're on I_HURT and we hit anything that should drop our item from the hands,
		we just ignore the click to it.
		*/
		return FALSE

	var/obj/item/weapon/W = parent

	var/is_stunned = is_type_in_list(target, interupt_on_sweep_hit_types)
	if(is_stunned)
		to_chat(user, "<span class='warning'>Your [W] has hit [target]! There's not enough space for broad sweeps here!</span>")

	var/resolved = target.attackby(W, user, list())
	if(!resolved && W)
		W.afterattack(target, user, TRUE, list()) // TRUE indicates adjacency

	return is_stunned

/*
 * Something we execute to all atoms on tile we're currently swiping through. e.g.: moving to next tile, if we're sweeping with a mop.
 * current_turf is the turf under sweep image right now.
 * next_turf is either null, or the next turf to be under sweep image.
 * sweep_image is the thing doing the sweep.
 * target is the target user clicked.
 * user is the one doing the sweeping.
 */
/datum/component/swiping/proc/sweep_to_check(turf/current_turf, turf/next_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/target, mob/user)
	if(on_sweep_to_check)
		on_sweep_to_check.Invoke(current_turf, next_turf, sweep_image, target, user)

// What happens if we swipe through the tile, but don't hit anything.
/datum/component/swiping/proc/sweep_finish(turf/current_turf, mob/living/user)
	if(on_sweep_finish)
		on_sweep_finish.Invoke(current_turf, user)

// What happens after we hit something.
/datum/component/swiping/proc/sweep_interupt(turf/current_turf, mob/living/user)
	if(on_sweep_interupt)
		on_sweep_interupt.Invoke(current_turf, user)
		return

	if(user.buckled)
		user.buckled.user_unbuckle_mob(user)
	// You hit a wall!
	user.apply_effect(2, STUN, 0)
	user.apply_effect(2, WEAKEN, 0)
	user.apply_effect(6, STUTTER, 0)
	shake_camera(user, 1, 1)
	// here be thud sound

#define SWEEP_CONTINUE "continue"
#define SWEEP_INTERUPT "interupt"
#define SWEEP_END "end"

// The working horse, the bread and butter of this component. Sweeping logic. Please use the wrapper - async_sweep.
/datum/component/swiping/proc/do_sweep(obj/effect/effect/weapon_sweep/sweep_image, mob/living/user, turf/current_turf, turf/next_turf)
	sweep_move(current_turf, sweep_image, user)

	var/list/to_check = list()
	to_check += current_turf.contents
	to_check += current_turf
	to_check -= sweep_image
	to_check -= user

	// Get out of the way, fellows!
	for(var/atom/A in to_check)
		// Like something behind a glass.
		if(!A.Adjacent(user))
			continue

		if(can_sweep_hit(A, user) && sweep_hit(current_turf, sweep_image, A, user))
			return SWEEP_INTERUPT

		sweep_to_check(current_turf, next_turf, sweep_image, A, user)
		// Just in case of some delaying/async bull.
		user.AdjustNextMove(sweep_image.sweep_delay + 1)

	if(sweep_image.next_dir == sweep_image.dirs_to_move.len)
		return SWEEP_END
	sweep_image.next_dir++
	return SWEEP_CONTINUE

// The handler for all the possible sweeping images, directions, and etc. Please use the wrapper - sweep.
/datum/component/swiping/proc/async_sweep(list/directions, mob/living/user, sweep_delay)
	var/obj/item/weapon/W = parent
	W.swiping = TRUE

	var/turf/start = get_step(W, directions[1])

	user.do_attack_animation(start)
	var/list/sweep_objects = get_sweep_objects(start, W, user, directions, sweep_delay)

	var/retVal = SWEEP_CONTINUE
	while(retVal == SWEEP_CONTINUE)
		for(var/obj/effect/effect/weapon_sweep/sweep_image in sweep_objects)
			var/dir_ = sweep_image.dirs_to_move[sweep_image.next_dir]
			var/turf/current_turf = get_step(W, dir_)

			user.SetNextMove(sweep_image.sweep_delay * directions.len + 1)

			INVOKE_ASYNC(src, .proc/move_sweep_image, current_turf, sweep_image)

		var/continue_sweep = sweep_continue_check(user, sweep_delay)
		if(!continue_sweep)
			retVal = SWEEP_END
			break

		for(var/obj/effect/effect/weapon_sweep/sweep_image in sweep_objects)
			var/dir_ = sweep_image.dirs_to_move[sweep_image.next_dir]
			var/turf/current_turf = get_step(W, dir_)

			var/turf/next_turf
			if(sweep_image.next_dir < sweep_image.dirs_to_move.len)
				var/next_dir = sweep_image.dirs_to_move[sweep_image.next_dir + 1]
				next_turf = get_step(W, next_dir)

			// Prioritize SWEEP_INTERUPT > SWEEP_END > SWEEP_CONTINUE
			var/newRetVal = do_sweep(sweep_image, user, current_turf, next_turf)
			sweep_finish(current_turf, user)
			switch(newRetVal)
				if(SWEEP_INTERUPT)
					retVal = SWEEP_INTERUPT
				if(SWEEP_END)
					if(retVal == SWEEP_CONTINUE)
						retVal = SWEEP_END

	if(retVal == SWEEP_INTERUPT)
		for(var/obj/effect/effect/weapon_sweep/sweep_image in sweep_objects)
			sweep_interupt(get_turf(sweep_image), user)

	for(var/obj/effect/effect/weapon_sweep/sweep_image in sweep_objects)
		QDEL_IN(sweep_image, sweep_image.sweep_delay)
	W.swiping = FALSE

// A tidy wrapper for the sweep logic, with neccesary checks.
/datum/component/swiping/proc/sweep(list/directions, mob/living/user, sweep_delay)
	if(can_sweep_call && !can_spin) // If it's a spinning thing, it has it's own check.
		can_sweep_call.Invoke(user)
		return COMSIG_ITEM_CANCEL_CLICKWITH

	var/obj/item/I = parent
	if(I.swiping)
		return

	INVOKE_ASYNC(src, .proc/async_sweep, directions, user, sweep_delay)

	return COMSIG_ITEM_CANCEL_CLICKWITH

// Swipe through the two adjacent to target tiles.
/datum/component/swiping/proc/sweep_facing(datum/source, atom/target, mob/user)
	if(!isturf(target) && !isturf(target.loc))
		return NONE

	if(can_sweep_call)
		if(!can_sweep_call.Invoke(target, user))
			return NONE

	var/obj/item/weapon/W = parent

	var/turf/T = get_turf(target)
	var/direction = get_dir(get_turf(W), T)
	var/list/directions = list(turn(direction, 45), direction, turn(direction, -45))
	sweep(directions, user, W.sweep_step)
	return COMSIG_ITEM_CANCEL_CLICKWITH

/*
	Procs related to spinning.
	Spinning is a sweep done across all 8 tiles, that surround the user.
*/
// A spin proc, a glorified 2x speed sweep.
/datum/component/swiping/proc/sweep_spin(datum/source, mob/user)
	if(can_spin_call)
		if(!can_spin_call.Invoke(user))
			return NONE

	if(on_spin)
		return on_spin.Invoke(user)

	var/rot_dir = 1
	if(user.dir == SOUTH || user.dir == WEST) // South-west rotate anti-clockwise.
		rot_dir = -1

	var/list/directions = list(user.dir, turn(user.dir, rot_dir * 45), turn(user.dir, rot_dir * 90), turn(user.dir, rot_dir * 135), turn(user.dir, rot_dir * 180), turn(user.dir, rot_dir * 225), turn(user.dir, rot_dir * 270), turn(user.dir, rot_dir * 315), user.dir)

	var/obj/item/weapon/W = parent

	INVOKE_ASYNC(src, .proc/sweep, directions, user, W.sweep_step * 0.5)
	return COMPONENT_NO_INTERACT

// A little bootleg for MiddleClick.
/datum/component/swiping/proc/sweep_spin_click(datum/source, atom/target, mob/user)
	if(!isturf(target) && !isturf(target.loc))
		return NONE

	if(sweep_spin(source, user) != NONE)
		return COMSIG_ITEM_CANCEL_CLICKWITH
	return NONE

// This proc processes all different mousedrop combos that activate swiping.
// Per say, swiping diagonally across makes you spin.
// Swiping away from you - to push.
// Swiping towards you - to pull.
// All other possible swipes that have all swipe-tiles in 1 tile range result in just a sweep.
/datum/component/swiping/proc/sweep_mousedrop(datum/source, atom/over, atom/dropping, mob/user)
	if(user.next_move > world.time || user.incapacitated())
		return NONE

	var/turf/over_turf = get_turf(over)
	var/turf/dropping_turf = get_turf(dropping)

	if(get_dir(user, over_turf) == reverse_direction(get_dir(user, dropping_turf)))
		if(can_spin && sweep_spin(parent, user) != NONE)
			return COMPONENT_NO_MOUSEDROP

	if(!istype(over_turf) || !istype(dropping_turf))
		return NONE

	var/list/turfs = getline(dropping_turf, over_turf)
	var/list/directions = list()
	for(var/turf/T in turfs)
		if(!in_range(user, T))
			if(get_dir(dropping, over) == get_dir(user, over))
				if(can_push && try_sweep_push(parent, over, user) != NONE)
					return COMPONENT_NO_MOUSEDROP
			else
				if(can_pull && try_sweep_pull(parent, dropping, user) != NONE)
					return COMPONENT_NO_MOUSEDROP
		directions += get_dir(user, T)

	var/obj/item/weapon/W = parent

	if(directions.len == 3 && can_sweep && sweep(directions, user, W.sweep_step) != NONE)
		return COMPONENT_NO_MOUSEDROP
	return NONE

#undef SWIPING_TIP
