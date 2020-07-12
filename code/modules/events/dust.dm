/*
Space dust
Commonish random event that causes small clumps of "space dust" to hit the station at high speeds.
No command report on the common version of this event.
The "dust" will damage the hull of the station causin minor hull breaches.
*/
/datum/event/dust
	var/qnty = 1

/datum/event/dust/setup()
	qnty = rand(1,5)

/datum/event/dust/start()
	var/startside = pick(cardinal)
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/turf/startT
	var/turf/endT
	for(var/i in 1 to qnty)
		startT = spaceDebrisStartLoc(startside, z)
		endT = spaceDebrisFinishLoc(startside, z)
		var/obj/effect/space_dust/weak/D = new(startT, endT)
		message_admins("[D] has spawned at [D.x],[D.y],[D.z] [ADMIN_JMP(D)] [ADMIN_FLW(D)].")

/obj/effect/space_dust
	name = "Space Dust"
	desc = "Dust in space."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "space_dust"
	density = 1
	anchored = 1
	var/strength = 2 //ex_act severity number
	var/life = 2 //how many things we hit before del(src)

/obj/effect/space_dust/weak
	strength = 3
	life = 1

/obj/effect/space_dust/strong
	strength = 1
	life = 6

/obj/effect/space_dust/super
	strength = 1
	life = 40


/obj/effect/space_dust/atom_init(mapload, turf/end)
	. = ..()
	INVOKE_ASYNC(src, .proc/check_location, end)

/obj/effect/space_dust/proc/check_location(turf/end)
	var/z_original = z
	if(end && end.z == z_original)
		walk_towards(src, end, 1)
	while(!QDELETED(src))
		if(loc == end || z != z_original)
			qdel(src)
			return
		sleep(1)

/obj/effect/space_dust/Bump(atom/A)
	if(prob(50))
		for(var/mob/M in range(10, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai))
				shake_camera(M, 3, 1)
	if(A)
		var/turf/T = get_turf(A)
		var/area/T_area = get_area(T)
		message_admins("<span class='warning'>[src] hit [A] in [T_area] [ADMIN_JMP(T)].</span>")
		log_game("[src] hit [A] ([T.x], [T.y], [T.z]) in [T_area].")

		playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)

		if(ismob(A))
			A.meteorhit(src)//This should work for now I guess
		else if(!istype(A, /obj/machinery/power/emitter) && !istype(A, /obj/machinery/field_generator)) //Protect the singularity from getting released every round!
			A.ex_act(strength) //Changing emitter/field gen ex_act would make it immune to bombs and C4

		life--
		if(life <= 0)
			walk(src, 0)
			QDEL_IN(src, 1)
			return 0
	return

/obj/effect/space_dust/ex_act(severity)
	qdel(src)
