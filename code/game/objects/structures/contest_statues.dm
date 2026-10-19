/obj/structure/contest_statue
	name = "statue"
	cases = list("статуя", "статуи", "статуе", "статую", "статуей", "статуе")
	desc = "Каменная статуя на пьедестале."
	icon = 'icons/obj/contest_statues.dmi'
	icon_state = "podium"
	anchored = TRUE
	density = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	resistance_flags = CAN_BE_HIT

	var/statue_state
	var/broken = FALSE

/obj/structure/contest_statue/atom_init()
	. = ..()
	update_statue_overlay()

/obj/structure/contest_statue/proc/update_statue_overlay()
	cut_overlays()
	if(!statue_state)
		return
	var/image/statue = image(icon, "[statue_state][broken ? "_damaged" : ""]")
	statue.pixel_y = 16
	add_overlay(statue)

/obj/structure/contest_statue/examine(mob/user)
	..()
	if(broken)
		to_chat(user, "<span class='warning'>Она вся в трещинах и едва держится.</span>")

/obj/structure/contest_statue/atom_break(damage_flag)
	. = ..()
	if(broken || !statue_state)
		return
	broken = TRUE
	playsound(src, 'sound/misc/sledgehammer_hit_rock.ogg', VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'>[C_CASE(src, NOMINATIVE_CASE)] трещит!</span>")
	update_statue_overlay()

/obj/structure/contest_statue/deconstruct(disassembled = TRUE)
	if(!disassembled)
		playsound(src, 'sound/effects/rockfall.ogg', VOL_EFFECTS_MASTER)
		if(statue_state)
			visible_message("<span class='danger'>[C_CASE(src, NOMINATIVE_CASE)] отламывается от пьедестала и падает навзничь!</span>")
			var/turf/fall_turf = get_turf(src)
			for(var/check_dir in shuffle(cardinal.Copy()))
				var/turf/T = get_step(src, check_dir)
				if(T && !T.density)
					fall_turf = T
					break
			var/obj/structure/fallen_statue/fallen = new(fall_turf)
			fallen.name = "fallen [name]"
			fallen.icon_state = "[statue_state]_damaged"
			new /obj/structure/contest_statue/pedestal(loc)
	return ..()

/obj/structure/contest_statue/pedestal
	name = "broken podium"
	cases = list("сломанный пьедестал", "сломанного пьедестала", "сломанному пьедесталу", "сломанный пьедестал", "сломанным пьедесталом", "сломанном пьедестале")
	desc = "На пьедестале осталась лишь пара каменных ступней."
	icon_state = "podium_damaged"
	max_integrity = 100
	integrity_failure = 0

/obj/structure/contest_statue/javelineer
	name = "statue of the javelineer"
	cases = list("статуя javelineer", "статуи javelineer", "статуе javelineer", "статую javelineer", "статуей javelineer", "статуе javelineer")
	desc = "Древний воин в шлеме с гребнем, застывший на полушаге. Табличка гласит: \"Победитель конкурса хэллоуинских костюмов\"."
	statue_state = "javeliin"

/obj/structure/contest_statue/replika
	name = "statue of the replika"
	cases = list("статуя replika", "статуи replika", "статуе replika", "статую replika", "статуей replika", "статуе replika")
	desc = "Каменная фигура андроида с бездушным взглядом». Табличка гласит: \"Победитель конкурса хэллоуинских костюмов\"."
	statue_state = "zero_inside"

var/global/list/contest_statue_spawns = list()
var/global/contest_statues_distributed = FALSE

/obj/effect/contest_statue_spawn
	name = "contest statue spawner"
	icon = 'icons/obj/contest_statues.dmi'
	icon_state = "podium"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/contest_statue_spawn/atom_init()
	. = ..()
	contest_statue_spawns += src
	return INITIALIZE_HINT_LATELOAD

/obj/effect/contest_statue_spawn/Destroy()
	contest_statue_spawns -= src
	return ..()

/obj/effect/contest_statue_spawn/atom_init_late()
	if(contest_statues_distributed)
		return
	contest_statues_distributed = TRUE
	var/list/pool = list(/obj/structure/contest_statue/javelineer, /obj/structure/contest_statue/replika)
	for(var/obj/effect/contest_statue_spawn/S as anything in shuffle(contest_statue_spawns.Copy()))
		if(pool.len)
			var/statue_type = pick_n_take(pool)
			new statue_type(S.loc)
		qdel(S)

/obj/structure/fallen_statue
	name = "fallen statue"
	cases = list("упавшая статуя", "упавшей статуи", "упавшей статуе", "упавшую статую", "упавшей статуей", "упавшей статуе")
	desc = "Потрескавшаяся каменная статуя лежит на полу. Тяжелая, но её всё ещё можно тащить."
	icon = 'icons/obj/contest_statues.dmi'
	anchored = FALSE
	density = FALSE
	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/fallen_statue/atom_init()
	. = ..()
	var/matrix/M = matrix()
	M.Turn(pick(90, -90))
	transform = M

/obj/structure/fallen_statue/deconstruct(disassembled = TRUE)
	if(!disassembled)
		playsound(src, 'sound/effects/rockfall.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>[C_CASE(src, NOMINATIVE_CASE)] рассыпается в пыль!</span>")
	return ..()
