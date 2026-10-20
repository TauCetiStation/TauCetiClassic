/obj/structure/statue_pedestal
	name = "statue"
	cases = list("статуя", "статуи", "статуе", "статую", "статуей", "статуе")
	desc = "Каменная статуя на пьедестале."
	icon = 'icons/obj/statues.dmi'
	icon_state = "podium"
	anchored = TRUE
	density = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	resistance_flags = CAN_BE_HIT

	var/obj/structure/fallen_statue/statue_part

/obj/structure/statue_pedestal/atom_init()
	. = ..()

	statue_part = new(src)
	statue_part.layer = INFRONT_MOB_LAYER
	statue_part.pixel_y = 16
	add_overlay(statue_part)

	name = statue_part.name

/obj/structure/statue_pedestal/atom_break(damage_flag)
	. = ..()
	if(!statue_part)
		return

	playsound(src, 'sound/effects/rockfall.ogg', VOL_EFFECTS_MASTER)
	visible_message("<span class='danger'>[C_CASE(src, NOMINATIVE_CASE)] отламывается от пьедестала и падает навзничь!</span>")

	var/turf/fall_turf = get_turf(src)
	for(var/check_dir in shuffle(cardinal.Copy()))
		var/turf/T = get_step(src, check_dir)
		if(T && !T.density)
			fall_turf = T
			break

	statue_part.forceMove(fall_turf)
	var/matrix/M = matrix()
	M.Turn(pick(90, -90))
	statue_part.layer = OBJ_LAYER
	statue_part.pixel_y = 0
	statue_part.transform = M
	statue_part = null

	cut_overlays()
	icon_state = "podium_broken"
	name = "broken statue"

/obj/structure/fallen_statue
	name = "fallen statue"
	cases = list("упавша¤ статуя", "упавшей статуи", "упавшей статуе", "упавшую статую", "упавшей статуей", "упавшей статуе")
	desc = "Каменная статуя лежит на полу. “тяжелая, но её всё ещё можно тащить."
	icon = 'icons/obj/statues.dmi'
	anchored = FALSE
	density = FALSE
	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/fallen_statue/atom_init()
	. = ..()

	icon_state = pick(icon_states(icon) - list("podium", "podium_broken"))
	name = icon_state

	color = STATUE_FILTER

/obj/structure/fallen_statue/deconstruct(disassembled = TRUE)
	if(!disassembled)
		playsound(src, 'sound/effects/rockfall.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>[C_CASE(src, NOMINATIVE_CASE)] рассыпается в пыль!</span>")
	return ..()
