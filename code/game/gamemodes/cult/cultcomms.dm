/obj/effect/proc_holder/spell/aoe_turf/cult_comms
	name = "Communion"
	action_icon_state = "cult_comms"
	action_background_icon_state = "bg_cult"
	charge_max = 3000
	clothes_req = 0



/obj/effect/proc_holder/spell/aoe_turf/cult_comms/cast_check(skipcharge = 0,mob/user = usr)
	if(!..())
		return 0
	if(!iscultist(usr) && !isshade(usr))
		return 0
	if(user.incapacitated())
		return 0
	return 1

/obj/effect/proc_holder/spell/aoe_turf/cult_comms/cast(list/targets, mob/living/user = usr)
	user.adjustBruteLoss(rand(10,25))
	call(/obj/effect/rune/proc/communicate)()

/mob/living/proc/remove_comms()
	for(var/obj/effect/proc_holder/spell/aoe_turf/cult_comms/C in spell_list)
		if(C.action)
			C.action.Remove(src)
		spell_list -= C
	if(mind)
		for(var/obj/effect/proc_holder/spell/aoe_turf/cult_comms/C in mind.spell_list)
			mind.spell_list -= C

/obj/effect/proc_holder/spell/aoe_turf/cult_comms/construct
	charge_max = 300

/obj/effect/proc_holder/spell/aoe_turf/cult_comms/construct/cast(list/targets, mob/user = usr)
	call(/obj/effect/rune/proc/communicate)()