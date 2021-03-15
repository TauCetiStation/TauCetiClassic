#define CHAPEL_LOOK  "Chapel looks"
#define RUNES        "Runes"
#define CONSTRUCTION "Construction"

/obj/item/weapon/storage/bible/tome
	name = "book"
	icon = 'icons/obj/cult.dmi'
	icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL

	religify_cd = 5 MINUTES

	var/static/list/build_next = list()
	var/build_cd = 1 MINUTE

	var/static/list/destr_next = list()
	var/destr_cd = 30 SECOND

	var/static/list/rune_next = list()
	var/rune_cd = 10 SECONDS
	var/scribe_time = 3 SECONDS
	var/scribing = FALSE

	var/static/list/build_choices_image = list()
	var/static/list/rune_choices_image = list()

	var/toggle_deconstruct = FALSE

	// Allows you to increase or decrease the costs
	var/cost_coef = 1

/obj/item/weapon/storage/bible/tome/atom_init()
	. = ..()
	rad_choices[CHAPEL_LOOK] = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "christianity_left")
	rad_choices[RUNES] = image(icon = 'icons/obj/rune.dmi', icon_state = "[rand(1, 6)]")
	rad_choices[CONSTRUCTION] = image(icon = 'icons/turf/walls/cult/runed_anim.dmi', icon_state = "box")

/obj/item/weapon/storage/bible/tome/examine(mob/user)
	if((iscultist(user) || isobserver(user)) && religion)
		to_chat(user, "Писание Нар-Си. Содержит подробности о тёмных ритуалах, загадочных рунах и много другой странной информации. Однако, большинство из написанного не работает.")
		to_chat(user, "Текущее количество favor: [religion.favor] piety: <span class='cult'>[religion.piety]</span>")
		var/list/L
		if(religion.runes_by_mob[user])
			L = religion.runes_by_mob[user]
		to_chat(user, "Вами нарисовано/всего <span class='cult'>[L ? L.len : "0"]</span>/[religion.max_runes_on_mob]")
	else
		..()

/obj/item/weapon/storage/bible/tome/pickup(mob/user)
	if(!religion && user.my_religion)
		religion = user.my_religion

/obj/item/weapon/storage/bible/tome/attack_self(mob/user)
	if(religion)
		if(build_choices_image.len - 1 < religion.available_buildings.len)
			building_choices()
		if(rune_choices_image.len < religion.available_runes.len)
			rune_choices()

	if(iscultist(user))
		choice_bible_func(user)
		return

	return ..()

/obj/item/weapon/storage/bible/tome/proc/can_destroy(atom/target, mob/user)
	if(istype(target, /obj/structure/altar_of_gods/cult) && religion.altars.len == 1)
		to_chat(user, "<span class='warning'>Вы не можете уничтожить последний алтарь.</span>")
		return FALSE
	if(istype(target, /obj/structure/cult/tech_table))
		var/obj/structure/cult/tech_table/T = target
		if(T.researching)
			to_chat(user, "<span class='warning'>Вы не можете уничтожить стол, пока идёт исследование.</span>")
			return FALSE
	return TRUE

/obj/item/weapon/storage/bible/tome/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!istype(religion, /datum/religion/cult))
		return

	var/datum/religion/cult/C = religion
	if(target.type in C.strange_anomalies)
		animate(target, 1 SECONDS, alpha = 0)
		sleep(1 SECONDS)
		religion.adjust_favor(rand(1, 5))
		qdel(target)
		destr_next[user.ckey] = world.time + destr_cd
		// statistics!
		score["destranomaly"]++
		return

	if(!toggle_deconstruct || !proximity)
		return

	if(destr_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>Ты сможешь уничтожить через [round((destr_next[user.ckey] - world.time) * 0.1)] секунд.</span>")
		return

	if(!can_destroy(target, user))
		return

	for(var/datum/building_agent/B in religion.available_buildings)
		if(istype(target, B.building_type))
			destr_next[user.ckey] = world.time + destr_cd
			animate(target, 2 SECONDS, alpha = 0)
			sleep(2 SECONDS)
			if(istype(target, /turf/simulated/wall/cult))
				var/turf/simulated/wall/cult/wall = target
				wall.dismantle_wall(TRUE)
			else if(isturf(target))
				var/turf/T = target
				var/type_new_turf = /turf/simulated/floor/plating
				if(istype(get_area(src), religion.area_type))
					type_new_turf = T.basetype
				T.ChangeTurf(type_new_turf)

			qdel(target)
			religion.adjust_favor(B.deconstruct_favor_cost * cost_coef)
			religion.adjust_piety(B.deconstruct_piety_cost * cost_coef)
			break

/obj/item/weapon/storage/bible/tome/proc/rune_choices()
	for(var/datum/building_agent/rune/cult/B in religion.available_runes)
		var/datum/rune/cult/R = new B.rune_type
		rune_choices_image[B] = image(icon = get_uristrune_cult(FALSE, R.words))
		qdel(R)

/obj/item/weapon/storage/bible/tome/proc/building_choices()
	build_choices_image["Toggle Grind mode"] = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind")
	for(var/datum/building_agent/B in religion.available_buildings)
		var/atom/build = B.building_type
		build_choices_image[B] = image(icon = initial(build.icon), icon_state = initial(build.icon_state))

/obj/item/weapon/storage/bible/tome/proc/scribe_rune(mob/living/carbon/human/H)
	var/datum/building_agent/rune/cult/choice = get_agent_radial_menu(rune_choices_image, H)
	if(!choice)
		return

	if(scribing)
		to_chat(H, "<span class='warning'>Вы уже рисуете руну!</span>")
		return

	if(rune_next[H.ckey] > world.time)
		to_chat(H, "<span class='warning'>Ты сможешь разметить следующую руну через [round((rune_next[H.ckey] - world.time) * 0.1)+1] секунд!</span>")
		return

	if(religion.runes_by_mob[H])
		var/list/L = religion.runes_by_mob[H]
		if(L.len > religion.max_runes_on_mob)
			to_chat(H, "<span class='warning'>Вуаль пространтсва не сможет сдержать больше рун!</span>")
			return

	if(!religion.check_costs(choice.favor_cost * cost_coef, choice.piety_cost * cost_coef, H))
		return

	scribing = TRUE
	if(!do_after(H, scribe_time, target = get_turf(H)))
		scribing = FALSE
		return
	scribing = FALSE

	H.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), ((rand(9) + 1) / 10))

	var/obj/effect/rune/R = new choice.building_type(get_turf(H), religion, H)
	R.icon = rune_choices_image[choice]
	R.power = new choice.rune_type(R)
	R.power.religion = religion
	R.blood_DNA = list()
	R.blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	new /obj/effect/temp_visual/cult/sparks(get_turf(R))

	religion.adjust_favor(-choice.favor_cost * cost_coef)
	religion.adjust_piety(-choice.piety_cost * cost_coef)
	rune_next[H.ckey] = world.time + rune_cd

/obj/item/weapon/storage/bible/tome/proc/building(mob/user)
	var/datum/building_agent/choice = get_agent_radial_menu(build_choices_image, user)
	if(!choice)
		return

	if(choice == "Toggle Grind mode")
		toggle_deconstruct = !toggle_deconstruct
		to_chat(user, "<span class='notice'>Режим разрушения структур [toggle_deconstruct ? "включён" : "выключен"].</span>")
		return

	if(build_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>Ты сможешь строить через [round((build_next[user.ckey] - world.time) * 0.1)+1] секунд.</span>")
		return

	if(!can_build_here(user))
		return FALSE

	if(ispath(choice.building_type, /obj/structure/altar_of_gods))
		var/turf/targeted_turf = get_step(src, user.dir)
		for(var/obj/structure/altar_of_gods/altar in religion.altars)
			if(targeted_turf.z == altar.z && get_dist_euclidian(targeted_turf, get_turf(altar)) <= 70)
				to_chat(user, "<span class='warning'>Ты не можешь построить второй алтарь недалеко от первого.</span>")
				return

	if(!religion.check_costs(choice.favor_cost * cost_coef, choice.piety_cost * cost_coef, user))
		return

	var/turf/targeted_turf = get_step(src, user.dir)
	if(ispath(choice.building_type, /turf))
		targeted_turf.ChangeTurf(choice.building_type)
	else if(ispath(choice.building_type, /obj/structure/altar_of_gods/cult))
		var/obj/structure/altar_of_gods/cult/altar = new(targeted_turf)
		altar.setup_altar(religion)
	else
		new choice.building_type(targeted_turf)

	new /obj/effect/temp_visual/cult/sparks(targeted_turf)

	religion.adjust_favor(-choice.favor_cost * cost_coef)
	religion.adjust_piety(-choice.piety_cost * cost_coef)
	build_next[user.ckey] = world.time + build_cd

/obj/item/weapon/storage/bible/tome/proc/choice_bible_func(mob/user)
	var/list/temp_images = list()
	var/list/choices = list(CHAPEL_LOOK, RUNES, CONSTRUCTION)
	if(user.mind.holy_role != CULT_ROLE_MASTER)
		choices -= CHAPEL_LOOK
	for(var/choose in choices)
		temp_images[choose] += rad_choices[choose]

	var/choice = show_radial_menu(user, src, temp_images, tooltips = TRUE, require_near = TRUE)
	switch(choice)
		if(CHAPEL_LOOK)
			change_chapel_looks(user)
		if(RUNES)
			scribe_rune(user)
		if(CONSTRUCTION)
			building(user)

/obj/item/weapon/storage/bible/tome/proc/get_agent_radial_menu(list/datum/building_agent/BA, mob/user)
	for(var/datum/building_agent/B in BA)
		B.name = "[initial(B.name)] [B.get_costs(cost_coef)]"

	var/datum/building_agent/choice = show_radial_menu(user, src, BA, tooltips = TRUE, require_near = TRUE)

	return choice

/obj/item/weapon/storage/bible/tome/proc/can_build_here(mob/user, datum/rune/rune)
	var/area/area = get_area(user)
	if(!religion.can_build_everywhere && !istype(religion, area.religion?.type))
		to_chat(user, "<span class='warning'>Вы можете строить только внутри зоны, подконтрольной вашей религией.</span>")
		return FALSE
	return TRUE

#undef CHAPEL_LOOK
#undef RUNES
#undef CONSTRUCTION
