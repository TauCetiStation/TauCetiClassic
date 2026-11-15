//Define all tape types in policetape.dm
/obj/item/taperoll
	name = "tape roll"
	icon = 'icons/obj/tape.dmi'
	icon_state = "rollstart"
	w_class = SIZE_TINY
	var/turf/start
	var/obj/effect/ebeam/tape/tape_type = /obj/effect/ebeam/tape
	var/icon_base

/obj/item/taperoll/police
	name = "police tape"
	desc = "Рулон полицейской оградительной ленты для оцепления мест преступления."
	icon_state = "police_start"
	tape_type = /obj/effect/ebeam/tape/police
	icon_base = "police"

/obj/effect/ebeam/tape/police
	name = "police tape"
	desc = "Полицейская оградительная лента. Не пересекать."
	icon_state = "policetape"
	req_one_access = list(access_security, access_forensics_lockers)

/obj/item/taperoll/engineering
	name = "engineering tape"
	desc = "Рулон инженерной оградительной ленты для оцепления мест проведения работ."
	icon_state = "engineering_start"
	tape_type = /obj/effect/ebeam/tape/engineering
	icon_base = "engineering"

/obj/effect/ebeam/tape/engineering
	name = "engineering tape"
	desc = "Инженерная оградительная лента. Не пересекать."
	icon_state = "engineeringtape"
	req_one_access = list(access_engine,access_atmospherics)

/obj/item/taperoll/science
	name = "science tape"
	desc = "Рулон белой оградительной ленты для оцепления опасных мест."
	icon_state = "science_start"
	tape_type = /obj/effect/ebeam/tape/science
	icon_base = "science"

/obj/effect/ebeam/tape/science
	name = "science tape"
	desc = "Белая оградительная лента. Не пересекать."
	icon_state = "sciencetape"
	req_one_access = list(access_research)

/obj/item/taperoll/attack_self(mob/user)
	if(!start)
		return ..()

	start = null
	icon_state = "[icon_base]_start"
	to_chat(user, "<span class='notice'>Вы стагиваете ленту.</span>")

/obj/item/taperoll/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	var/turf/T = get_turf(target)

	if(start)
		if(get_dist(start, T) > 5)
			to_chat(user, "<span class='warning'>Слишком большое расстояние!</span>")
			return

		var/datum/beam/beam = start.Beam(target, tape_type::icon_state, time=INFINITY, maxdistance=10, beam_type=tape_type, loose_factor = 0.7, dense_beam = TRUE)
		if(!beam)
			return

		var/obj/effect/ebeam/tape/tape = pick(beam.elements)
		user.visible_message("<span class='notice'>[user] натягивает [CASE(tape, ACCUSATIVE_CASE)].</span>")
		start = null
		icon_state = "[icon_base]_start"
		return

	to_chat(user, "<span class='notice'>Вы начинаете натягивать ленту.</span>")
	icon_state = "[icon_base]_stop"
	start = T


/obj/effect/ebeam/tape
	cases = list("оградительная лента", "оградительной ленты", "оградительной ленте", "оградительную ленту", "оградительной лентой", "оградительной ленте")
	mouse_opacity = MOUSE_OPACITY_ICON
	layer = INFRONT_MOB_LAYER

/obj/effect/ebeam/tape/CanPass(atom/movable/mover, turf/target, height=0)
	if(!density)
		return TRUE
	if(allowed(mover))
		return TRUE
	if (mover.pass_flags & (PASSTABLE | PASSCRAWL) || istype(mover, /obj/effect/meteor) || mover.throwing)
		return TRUE
	else
		return FALSE

/obj/effect/ebeam/tape/attackby(obj/item/I, mob/user, params)
	. = ..()
	breaktape(I, user, FALSE)
	user.SetNextMove(CLICK_CD_INTERACT)

/obj/effect/ebeam/tape/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if (user.a_intent == INTENT_HELP && allowed(user))
		if(!density)
			return

		user.visible_message("<span class='notice'>[user] приподнимает [CASE(src, ACCUSATIVE_CASE)], позволяя пройти.</span>")
		set_passage()
	else
		breaktape(null, user, FALSE)

/obj/effect/ebeam/tape/proc/set_passage()
	owner.loose_factor = -1
	owner.dense_beam = FALSE
	VARSET_IN(owner, loose_factor, 0.7, 4 SECONDS)
	VARSET_IN(owner, dense_beam, TRUE, 4 SECONDS)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/datum/beam, recalculate), TRUE), 5 SECONDS)

	owner.recalculate(force_redraw = TRUE)

/obj/effect/ebeam/tape/attack_paw(mob/user)
	breaktape(null, user, FALSE)

/obj/effect/ebeam/tape/attack_alien(mob/user)
	breaktape(W = null, user = user, forced = FALSE)

/obj/effect/ebeam/tape/attack_animal(mob/living/simple_animal/M)
	breaktape(W = null, user = M, forced = FALSE)

/obj/effect/ebeam/tape/blob_act()
	breaktape(W = null, user = null, forced = TRUE)

/obj/effect/ebeam/tape/ex_act()
	breaktape(W = null, user = null, forced = TRUE)

/obj/effect/ebeam/tape/Bumped(atom/movable/AM)
	if(istype(AM, /obj/mecha))
		breaktape(W = null, user = null, forced = TRUE)
	else if(isliving(AM))
		var/mob/living/L = AM
		if(L.a_intent == INTENT_HARM)
			breaktape(W = null, user = L, forced = FALSE)

/obj/effect/ebeam/tape/proc/breaktape(obj/item/weapon/W, mob/user, forced = FALSE)
	if((user && user.a_intent == INTENT_HELP) && (W && !W.can_puncture() && allowed(user)) && !forced)
		to_chat(user, "<span class='warning'>Нельзя порвать [CASE(src, ACCUSATIVE_CASE)] этим!</span>")
		return

	if(user)
		user.visible_message("<span class='notice'>[user] рвёт [CASE(src, ACCUSATIVE_CASE)]!</span>")


	owner.End()
