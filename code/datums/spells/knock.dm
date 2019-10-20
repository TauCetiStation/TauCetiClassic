/obj/effect/proc_holder/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."
	sound = 'sound/magic/Knock.ogg'
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 3

	action_icon_state = "knock"

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			if(istype(door, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/A = door
				INVOKE_ASYNC(A, /obj/machinery/door/airlock/proc/unbolt)
			INVOKE_ASYNC(door, /obj/machinery/door/proc/open)
		for(var/obj/structure/closet/C in T.contents)
			C.locked = 0
			INVOKE_ASYNC(C, /obj/structure/closet/proc/open)
	return
