//Define all tape types in policetape.dm
/obj/item/taperoll
	name = "tape roll"
	icon = 'icons/obj/tape.dmi'
	icon_state = "rollstart"
	w_class = ITEM_SIZE_SMALL
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/tape
	var/icon_base

/obj/item/tape
	name = "tape"
	icon = 'icons/obj/tape.dmi'
	anchored = 1
	density = 1
	var/icon_base

/obj/item/taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/tape/police
	icon_base = "police"

/obj/item/tape/police
	name = "police tape"
	desc = "A length of police tape. Do not cross."
	req_one_access = list(access_security, access_forensics_lockers)
	icon_base = "police"

/obj/item/taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/tape/engineering
	icon_base = "engineering"

/obj/item/tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_one_access = list(access_engine,access_atmospherics)
	icon_base = "engineering"

/obj/item/taperoll/science
	name = "science tape"
	desc = "A roll of science tape used to block off things scientists dont want you to touch."
	icon_state = "science_start"
	tape_type = /obj/item/tape/science
	icon_base = "science"

/obj/item/tape/science
	name = "science tape"
	desc = "A snow-white science tape. Should you cross it?"
	req_one_access = list(access_research)
	icon_base = "science"

/obj/item/taperoll/attack_self(mob/user)
	if(icon_state == "[icon_base]_start")
		start = get_turf(src)
		to_chat(usr, "<span class='notice'>You place the first end of the [src].</span>")
		icon_state = "[icon_base]_stop"
	else
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(usr, "<span class='notice'>[src] can only be laid horizontally or vertically.</span>")
			return

		var/turf/cur = start
		var/dir
		if (start.x == end.x)
			var/d = end.y-start.y
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		var/can_place = 1
		while (cur!=end && can_place)
			if(cur.density == 1)
				can_place = 0
			else if (istype(cur, /turf/space))
				can_place = 0
			else
				for(var/obj/O in cur)
					if(!istype(O, /obj/item/tape) && O.density)
						can_place = 0
						break
			cur = get_step_towards(cur,end)
		if (!can_place)
			to_chat(usr, "<span class='notice'>You can't run \the [src] through that!</span>")
			return

		cur = start
		var/tapetest = 0
		while (cur!=end)
			for(var/obj/item/tape/Ptest in cur)
				if(Ptest.icon_state == "[Ptest.icon_base]_[dir]")
					tapetest = 1
			if(tapetest != 1)
				var/obj/item/tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
			cur = get_step_towards(cur,end)
		to_chat(usr, "<span class='notice'>You finish placing the [src].</span>")

/obj/item/taperoll/afterattack(atom/target, mob/user, proximity, params)
	if (istype(target, /obj/machinery/door/airlock))
		if(!user.Adjacent(target))
			to_chat(user, "<span class='notice'>You're too far away from \the [target]!</span>")
			return
		var/turf/T = get_turf(target)
		var/obj/item/tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[icon_base]_door"
		P.layer = 3.2
		to_chat(user, "<span class='notice'>You finish placing the [src].</span>")

/obj/item/tape/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!density)
		return TRUE
	if(air_group || (height == 0))
		return TRUE
	if(allowed(mover))
		return TRUE
	if (mover.pass_flags & (PASSTABLE | PASSCRAWL) || istype(mover, /obj/effect/meteor) || mover.throwing)
		return TRUE
	else
		return FALSE

/obj/item/tape/attackby(obj/item/I, mob/user, params)
	. = ..()
	breaktape(I, user, FALSE)
	user.SetNextMove(CLICK_CD_INTERACT)

/obj/item/tape/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if (user.a_intent == INTENT_HELP && allowed(user))
		user.visible_message("<span class='notice'>[user] lifts [src], allowing passage.</span>")
		density = 0
		addtimer(VARSET_CALLBACK(src, density, TRUE), 20 SECONDS)
	else
		breaktape(null, user, FALSE)

/obj/item/tape/attack_paw(mob/user)
	breaktape(null, user, FALSE)

/obj/item/tape/attack_alien(mob/user)
	breaktape(W = null, user = user, forced = FALSE)

/obj/item/tape/attack_animal(mob/living/simple_animal/M)
	breaktape(W = null, user = M, forced = FALSE)

/obj/item/tape/blob_act()
	breaktape(W = null, user = null, forced = TRUE)

/obj/item/tape/ex_act()
	breaktape(W = null, user = null, forced = TRUE)

/obj/item/tape/Bumped(atom/movable/AM)
	if(istype(AM, /obj/mecha))
		breaktape(W = null, user = null, forced = TRUE)
	else if(isliving(AM))
		var/mob/living/L = AM
		if(L.a_intent == INTENT_HARM)
			breaktape(W = null, user = L, forced = FALSE)

/obj/item/tape/proc/breaktape(obj/item/weapon/W, mob/user, forced = FALSE)
	if((user && user.a_intent == INTENT_HELP) && (W && !W.can_puncture() && allowed(user)) && !forced)
		to_chat(user, "<span class='warning'>You can't break the [src] with that!</span>")
		return
	if(user)
		user.visible_message("<span class='notice'>[user] breaks the [src]!</span>")

	var/dir[2]
	var/icon_dir = icon_state
	if(icon_dir == "[src.icon_base]_h")
		dir[1] = EAST
		dir[2] = WEST
	if(icon_dir == "[src.icon_base]_v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i = 1 to 2)
		var/N = 0
		var/turf/cur = get_step(src,dir[i])
		while(N != 1)
			N = 1
			for (var/obj/item/tape/P in cur)
				if(P.icon_state == icon_dir)
					N = 0
					qdel(P)
			cur = get_step(cur,dir[i])

	qdel(src)
	return
