/obj/effect/proc_holder/spell/aoe_turf/knock
	name = "Стук"
	desc = "Открывает любые ближайшие двери. Даже запертые. Не требует одежды для использования."
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
				INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, unbolt))
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open))
		for(var/obj/structure/closet/C in T.contents)
			C.locked = 0
			INVOKE_ASYNC(C, TYPE_PROC_REF(/obj/structure/closet, open))
	return
