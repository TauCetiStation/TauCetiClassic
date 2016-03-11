//*************-Pad-*************//

/obj/machinery/abductor/pad
	name = "alien telepad"
	desc = "Use this to transport to and from human habitat."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	anchored = 1
	var/area/teleport_target
	var/target_name

/obj/machinery/abductor/proc/TeleportToArea(var/mob/living/target,var/area/thearea)
	var/list/L = list()
	if(!thearea)	return
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		return

	if(target && target.buckled)
		target.buckled.unbuckle_mob()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	while(tempL.len)
		attempt = pick(tempL)
		target.Move(attempt)
		if(get_turf(target) == attempt)
			success = 1
			break
		else
			tempL.Remove(attempt)
	if(!success)
		target.loc = pick(L)

/obj/machinery/abductor/pad/proc/Warp(var/mob/living/target)
	if(target)

		//prevent from teleporting victim though the grab on neck
		if(istype(target.get_active_hand(),/obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = target.get_active_hand()
			if(G.state >= GRAB_PASSIVE)
				if(istype(target.l_hand, G))
					target.drop_l_hand()
				else
					target.drop_r_hand()
		if(istype(target.get_inactive_hand(),/obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = target.get_inactive_hand()
			if(G.state >= GRAB_PASSIVE)
				if(istype(target.l_hand, G))
					target.drop_l_hand()
				else
					target.drop_r_hand()

		target.Move(src.loc)

/obj/machinery/abductor/pad/proc/Send()
	flick("alien-pad", src)
	for(var/mob/living/target in src.loc)
		TeleportToArea(target,teleport_target)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/Retrieve(var/mob/living/target)
	if(!target) return
	flick("alien-pad", src)
	spawn(0)
		anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)
	Warp(target)
