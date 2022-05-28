/obj/effect/proc_holder/spell/aoe_turf/lepr_escape
	name = "Побег"
	desc = "Возвращает вас в логово Жадности."
	clothes_req = 0
	charge_max = 50
	var/list/turf/possible_tile
	var/target
	action_icon_state = "spell_default"

/obj/effect/proc_holder/spell/aoe_turf/lepr_escape/cast(mob/user = usr)
	possible_tile = get_area_turfs(get_area_by_type(/area/lepr))
	target = pick(possible_tile)
	playsound(usr, 'sound/Event/lepr_escape.ogg', VOL_EFFECTS_MASTER)
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr.loc)
	smoke.start()
	usr.loc = target


