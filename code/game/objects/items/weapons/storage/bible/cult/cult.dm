// TODO: Write normal text gde nado
/obj/item/weapon/storage/bible/tome
	name = "book"
	icon = 'icons/obj/cult.dmi'
	icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL

	religify_cd = 5 MINUTES

	var/build_next = list()
	var/build_cd = 30 SECONDS
	var/destr_cd = 1 SECOND
	var/destr_next = list()

	var/rune_next = list()
	var/rune_cd = 10 SECONDS

	var/list/choices_generated = FALSE
	var/static/list/build_choices_image = list()
	var/static/list/rune_choices_image = list()

	var/toggle_deconstruct = FALSE

/obj/item/weapon/storage/bible/tome/atom_init()
	. = ..()
	rad_choices["Chapel looks"] = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "christianity_left")
	rad_choices["Runes"] = image(icon = 'icons/obj/rune.dmi', icon_state = "[rand(1, 6)]")
	rad_choices["Construction"] = image(icon = 'icons/turf/walls/cult/wall.dmi', icon_state = "box")

/obj/item/weapon/storage/bible/tome/examine(mob/user)
	if(iscultist(user) || isobserver(user))
		to_chat(user, "Current count of favor: [religion.favor]; piety: <span class='piety'>[religion.piety]</span>")
	else
		..()

/obj/item/weapon/storage/bible/tome/attack_self(mob/user)
	if(religion && !choices_generated)
		building_choices()
		rune_choices()
		choices_generated = TRUE

	if(user.mind && user.mind.holy_role && istype(user.mind.my_religion, /datum/religion/cult))
		choice_bible_func(user)
		return

	return ..()

/obj/item/weapon/storage/bible/tome/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!toggle_deconstruct)
		return

	if(destr_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>YOU CANT DESTROY! Please wait about [round((destr_next[user.ckey] - world.time) * 0.1)] seconds to try again.</span>")
		return

	if(target.type in religion.strange_anomalies)
		animate(target, 1 SECONDS, alpha = 0)
		sleep(1 SECONDS)
		religion.adjust_favor(rand(1, 5))
		qdel(target)
		destr_next[user.ckey] = world.time + destr_cd
		return

	for(var/datum/building_agent/B in religion.available_buildings)
		if(istype(target, B.building_type))
			if(!religion.check_costs(B.deconstruct_favor_cost, B.deconstruct_piety_cost, user))
				break

			destr_next[user.ckey] = world.time + destr_cd
			animate(target, 2 SECONDS, alpha = 0)
			sleep(2 SECONDS)
			if(istype(target, /turf/simulated/wall/cult))
				var/turf/simulated/wall/cult/C = target
				C.dismantle_wall(TRUE)
			else if(isturf(target))
				var/turf/T = target
				var/type_new_turf = /turf/simulated/floor/plating
				if(istype(get_area(src), /area/custom/cult))
					type_new_turf = T.basetype
				T.ChangeTurf(type_new_turf)

			qdel(target)
			religion.adjust_favor(-B.deconstruct_favor_cost)
			religion.adjust_piety(-B.deconstruct_piety_cost)
			break

// TODO: do func
/obj/item/weapon/storage/bible/tome/proc/rune_choices()
	return

/obj/item/weapon/storage/bible/tome/proc/building_choices()
	build_choices_image["Toggle Grind mode"] = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind")
	for(var/datum/building_agent/B in religion.available_buildings)
		var/atom/build = B.building_type
		build_choices_image[B] = image(icon = initial(build.icon), icon_state = initial(build.icon_state))

/obj/item/weapon/storage/bible/tome/proc/scribe_rune(mob/user)
	if(rune_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>YOU CANT SCRIBE RUNE! Please wait about [round((rune_next[user.ckey] - world.time) * 0.1)] seconds to try again.</span>")
		return

	rune_next[user.ckey] = world.time + rune_cd

/obj/item/weapon/storage/bible/tome/proc/building(mob/user)
	if(build_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>YOU CANT BUILD! Please wait about [round((build_next[user.ckey] - world.time) * 0.1)] seconds to try again.</span>")
		return

	for(var/datum/building_agent/B in build_choices_image)
		B.name = "[initial(B.name)] [B.get_costs()]"

	var/datum/building_agent/choice = show_radial_menu(user, src, build_choices_image, tooltips = TRUE, require_near = TRUE)
	if(!choice)
		return

	if(choice == "Toggle Grind mode")
		toggle_deconstruct = !toggle_deconstruct
		to_chat(user, "<span class='notice'>The mode of destruction of constructed structures is [toggle_deconstruct ? "enabled" : "disabled"].</span>")
		return

	else if(ispath(choice.building_type, /obj/structure/altar_of_gods/cult) && religion.altar)
		to_chat(user, "<span class='warning'>YOU CANT BUID ANOTHER ALTAR</span>")
		return

	if(!religion.check_costs(choice.favor_cost, choice.piety_cost, user))
		return

	var/turf/targeted_turf = get_step(src, user.dir)
	if(ispath(choice.building_type, /turf))
		targeted_turf.ChangeTurf(choice.building_type)
	else
		new choice.building_type(targeted_turf)

	religion.adjust_favor(-choice.favor_cost)
	religion.adjust_piety(-choice.piety_cost)
	build_next[user.ckey] = world.time + build_cd

/obj/item/weapon/storage/bible/tome/proc/choice_bible_func(mob/user)
	var/list/temp_images = list()
	var/list/choices = list("Chapel looks", "Runes", "Construction")
	for(var/choose in choices)
		temp_images[choose] += rad_choices[choose]

	var/choice = show_radial_menu(user, src, temp_images, tooltips = TRUE, require_near = TRUE)
	switch(choice)
		if("Chapel looks")
			change_chapel_looks(user)
		if("Runes")
			scribe_rune(user)
		if("Construction")
			building(user)
