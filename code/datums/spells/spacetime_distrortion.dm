/obj/effect/proc_holder/spell/targeted/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of spacetime to deny easy movement around you. The strings vibrate..."
	charge_max = 700
	var/duration = 150
	range = 7
	var/list/effects
	var/ready = TRUE
	centcomm_cancast = FALSE

/obj/effect/proc_holder/spell/targeted/spacetime_dist/can_cast(mob/user = usr)
	if(ready && ..())
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/spacetime_dist/choose_targets(mob/user = usr)
	var/list/turfs = spiral_range_turfs(range, user)
	if(!turfs.len)
		revert_cast()
		return

	ready = FALSE
	var/list/turf_steps = list()
	var/length = round(turfs.len * 0.5)
	for(var/i in 1 to length)
		turf_steps[pick_n_take(turfs)] = pick_n_take(turfs)
	perform(turf_steps)

/obj/effect/proc_holder/spell/targeted/spacetime_dist/after_cast(list/targets)
	addtimer(CALLBACK(src, .proc/clean_turfs), duration)

/obj/effect/proc_holder/spell/targeted/spacetime_dist/cast(list/targets, mob/user = usr)
	effects = list()
	for(var/turf/V in targets)
		var/turf/T0 = V
		var/turf/T1 = targets[V]
		var/obj/effect/cross_action/spacetime_dist/STD0 = new(T0)
		var/obj/effect/cross_action/spacetime_dist/STD1 = new(T1)
		STD0.linked_dist = STD1
		STD1.linked_dist = STD0
		effects += STD0
		effects += STD1

/obj/effect/proc_holder/spell/targeted/spacetime_dist/proc/clean_turfs()
	for(var/effect in effects)
		qdel(effect)
	effects.Cut()
	effects = null
	ready = TRUE

/obj/effect/cross_action
	name = "cross me"
	desc = "for crossing"
	icon = 'icons/effects/effects.dmi'
	anchored = 1

/obj/effect/cross_action/spacetime_dist
	name = "spacetime distortion"
	desc = "A distortion in spacetime. You can hear faint music..."
	icon_state = "wave1"
	color = "#8a2be2"
	var/obj/effect/cross_action/spacetime_dist/linked_dist
	var/busy = FALSE
	var/sound
	var/walks_left = 50 //prevents the game from hanging in extreme cases (such as minigun fire)
	var/static/list/guitar_notes = null

/obj/effect/cross_action/spacetime_dist/atom_init()
	. = ..()
	if(!guitar_notes)
		guitar_notes = list("Fn3","F#3","Gb3","Gn3","G#3","Ab3","An3","A#3","Bb3","Bn3","B#3","Cb4","Cn4","C#4","Db4","Dn4",
							"D#4","Eb4","En4","E#4","Fb4","Fn4","F#4","Gb4","Gn4","G#4","Ab4","An4","A#4","Bb4","Bn4","B#4",
							"Cb5","Cn5","C#5","Db5","Dn5","D#5","Eb5","En5","E#5","Fb5","Fn5","F#5","Gb5","Gn5","G#5","Ab5",
							"An5","A#5","Bb5","Bn5","B#5","Cb6","Cn6","C#6","Db6","Dn6","D#6","Eb6","En6","E#6","Fb6","Fn6",
							"F#6","Gb6","Gn6","G#6","Ab6","An6","A#6","Bb6","Bn6","Cb7")
	sound = file("code/modules/musical_instruments/sound/guitar/[safepick(guitar_notes)].ogg")

/obj/effect/cross_action/spacetime_dist/proc/walk_link(atom/movable/AM)
	if(linked_dist && walks_left > 0 && !AM.freeze_movement)
		flick("purplesparkles", src)
		linked_dist.get_walker(AM)
		walks_left--

/obj/effect/cross_action/spacetime_dist/proc/get_walker(atom/movable/AM)
	busy = TRUE
	flick("purplesparkles", src)
	AM.forceMove(get_turf(src))
	playsound(AM, sound, VOL_EFFECTS_MASTER)
	busy = FALSE

/obj/effect/cross_action/spacetime_dist/Crossed(atom/movable/AM)
	. = ..()
	if(!busy)
		walk_link(AM)

/obj/effect/cross_action/spacetime_dist/attackby(obj/item/W, mob/user, params)
	if(user.drop_item(W))
		walk_link(W)
	else
		walk_link(user)

/obj/effect/cross_action/spacetime_dist/attack_hand(mob/user)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/attack_paw(mob/user)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/Destroy()
	busy = TRUE
	linked_dist = null
	return ..()
