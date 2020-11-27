/obj/effect/proc_holder/spell/targeted/harmless_sparks
	name = "Sparks!"
	desc = "This spell summons a few bright sparks!"
	range = 1
	school = "mousefaction"
	clothes_req = 0
	charge_max = 120
	action_icon_state = "hsparks"

/obj/effect/proc_holder/spell/targeted/harmless_sparks/choose_targets(mob/user = usr)
	new /obj/effect/effect/sparks(get_turf(usr))
	perform()
	
