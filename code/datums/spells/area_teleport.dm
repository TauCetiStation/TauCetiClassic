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
	invocation(thearea)
	after_cast(targets)

/obj/effect/proc_holder/spell/targeted/area_teleport/before_cast(list/targets)
	for(var/mob/living/target in targets)
		if(target.incapacitated() || target.lying)
			return FALSE
	var/A = null
	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) in teleportlocs
	else
		A = pick(teleportlocs)

	var/area/thearea = teleportlocs[A]
	playsound(usr,'sound/magic/Teleport_diss.ogg',100,2)
	if(do_after(usr, 50, target = usr))
		return thearea
	else
		return FALSE

/obj/effect/proc_holder/spell/targeted/area_teleport/cast(list/targets,area/thearea)
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
		target.forceMove(pick(L))