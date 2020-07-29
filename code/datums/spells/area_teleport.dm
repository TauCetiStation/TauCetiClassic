/obj/effect/proc_holder/spell/targeted/area_teleport
	name = "Area teleport"
	desc = "This spell teleports you to a type of area of your selection."
	sound = 'sound/magic/Teleport_App.ogg'
	var/randomise_selection = 0 //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = 1 //if the invocation appends the selected area

/obj/effect/proc_holder/spell/targeted/area_teleport/perform(list/targets, recharge = 1)
	var/thearea = before_cast(targets)
	if(!thearea || !cast_check(1))
		revert_cast()
		return
	if(charge_type == "recharge" && recharge)
		INVOKE_ASYNC(src, .proc/start_recharge)
	cast(targets,thearea)
	invocation()

/obj/effect/proc_holder/spell/targeted/area_teleport/before_cast(list/targets)
	for(var/mob/living/target in targets)
		if(target.incapacitated() || target.lying)
			return FALSE
	var/A = null
	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) as null|anything  in teleportlocs
	else
		A = pick(teleportlocs)

	if(!A)
		return FALSE
	var/area/thearea = teleportlocs[A]
	usr.say("SCYAR NILA [thearea.name]")
	if(do_after(usr, 50, target = usr))
		playsound(usr,'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
		return thearea
	else
		return FALSE

/obj/effect/proc_holder/spell/targeted/area_teleport/cast(list/targets, area/thearea)
	for(var/mob/living/target in targets)
		var/list/L = list()
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
			to_chat(usr, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
			return
		var/turf/T = pick(L)
		target.forceMove(T)
		handle_teleport_grab(T, target)

/obj/proc/handle_teleport_grab(atom/T, mob/living/U)
	var/atom/teleport_place
	if(isturf(T))
		teleport_place = locate(T.x + rand(-1,1), T.y + rand(-1,1), T.z)
	else
		teleport_place = T
	var/list/returned = list()
	for(var/obj/item/weapon/grab/G in U.GetGrabs())
		returned += G.affecting
		G.affecting.forceMove(teleport_place)
	if(length(returned))
		return returned
	return null
