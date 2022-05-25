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
	usr.loc = target

