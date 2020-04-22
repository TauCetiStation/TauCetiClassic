var/timestop_count = 0

/obj/effect/timestop
	anchored = 1
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	mouse_opacity = 0
	bound_height = 160
	bound_width = 160
	bound_x = -64
	bound_y = -64
	var/list/immune = list() // the one who creates the timestop is immune
	var/list/stopped_atoms = list()
	var/freezerange = 2
	var/duration = 14 SECONDS
	alpha = 125

/obj/effect/timestop/atom_init()
	. = ..()
	timestop_count++
	playsound(src, 'sound/magic/TIMEPARADOX2.ogg', VOL_EFFECTS_MASTER)
	timestop()
	QDEL_IN(src, duration)

/obj/effect/timestop/Destroy()
	timestop_count--
	untimestop()
	LAZYCLEARLIST(immune)
	LAZYCLEARLIST(stopped_atoms)

	return ..()

/obj/effect/timestop/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM) && !isobj(AM))
		return
	timestop(AM)

/obj/effect/timestop/Uncrossed(atom/movable/AM)
	if(!isliving(AM) && !isobj(AM))
		return
	untimestop(AM)

/obj/effect/timestop/proc/timestop(atom/movable/target)
	var/list/catched_targets = list()
	if(target)
		catched_targets += target
	else
		catched_targets += obounds()

	if(!length(catched_targets))
		return

	for(var/AM in catched_targets)
		if(isliving(AM))

			var/mob/living/M = AM
			if(M.mind)
				for(var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/T in M.mind.spell_list) //People who can stop time are immune to timestop
					immune |= M
			if(M in immune)
				continue

			if(istype(M, /mob/living/simple_animal/hostile))
				var/mob/living/simple_animal/hostile/H = M
				H.LoseTarget()

			M.Stun(10, 1, 1, 1)
			M.freeze_movement = TRUE
			stopped_atoms |= M

		else if(isobj(AM))
			var/obj/O = AM
			if(istype(O, /obj/item/projectile))
				var/obj/item/projectile/P = O
				P.paused = TRUE // just so it won't keep trying to move while freezed.

			O.freeze_movement = TRUE
			stopped_atoms |= O

/obj/effect/timestop/proc/untimestop(atom/movable/target)
	var/list/catched_targets = list()
	if(target)
		if(!(target in stopped_atoms))
			catched_targets += target
	else
		catched_targets = stopped_atoms

	if(!length(catched_targets))
		return

	for(var/atom/movable/AM in catched_targets)
		AM.freeze_movement = FALSE

		if(isliving(AM))
			var/mob/living/M = AM
			M.AdjustStunned(-10, 1, 1, 0)

		if(istype(AM, /obj/item/projectile))
			var/obj/item/projectile/P = AM
			P.paused = FALSE

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	charge_max = 500
	clothes_req = 1
	invocation = "TOKI WO TOMARE"
	invocation_type = "shout"
	range = 0
	summon_amt = 1
	action_icon_state = "time"
	newVars = list("duration" = 140)
	summon_type = list(/obj/effect/timestop)
