var/global/numbers_of_timestop = 0

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
	var/mob/living/immune = list() // the one who creates the timestop is immune
	var/list/stopped_atoms = list()
	var/freezerange = 2
	var/duration = 140
	alpha = 125

/obj/effect/timestop/New()
	..()
	numbers_of_timestop++
	timestop()

/obj/effect/timestop/Destroy()
	numbers_of_timestop--
	return ..()

/obj/effect/timestop/proc/timestop()
	playsound(src, 'sound/magic/TIMEPARADOX2.ogg', 100, 1, -1)
	for(var/i in 1 to duration-1)
		for(var/atom/A in range(freezerange,loc))
			if(isliving(A))
				var/mob/living/M = A
				if(M.mind)
					for(var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/T in M.mind.spell_list) //People who can stop time are immune to timestop
						immune |= M
				if(M in immune)
					continue
				M.Stun(10, 1, 1)
				M.anchored = 1
				if(istype(M,/mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					H.LoseTarget()
				stopped_atoms |= M
			else if(istype(A, /obj/item/projectile))
				var/obj/item/projectile/P = A
				P.hitscan = TRUE
				P.paused = TRUE
				stopped_atoms |= P

		for(var/mob/living/M in stopped_atoms)
			if(get_dist(get_turf(M), get_turf(src)) > freezerange) //If they lagged/ran past the timestop somehow, just ignore them
				unfreeze_mob(M)
				stopped_atoms -= M
		stoplag()

	//End
	for(var/mob/living/M in stopped_atoms)
		unfreeze_mob(M)

	for(var/obj/item/projectile/P in stopped_atoms)
		P.hitscan = initial(P.hitscan)
		P.paused = FALSE
	qdel(src)
	return

/obj/effect/timestop/proc/unfreeze_mob(mob/living/M)
	M.AdjustStunned(-10, 1, 1)
	M.anchored = 0

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