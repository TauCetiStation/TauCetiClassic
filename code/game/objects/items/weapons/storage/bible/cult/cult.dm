// TODO: Write normal text gde nado
/obj/item/weapon/storage/bible/tome
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL

	religify_cd = 5 MINUTES

	var/build_next = list()
	var/build_cd = 30 SECONDS

	var/rune_next = list()
	var/rune_cd = 10 SECONDS

	var/list/choices_generated = FALSE
	var/list/build_choices_image = list()
	var/list/rune_choices_image = list()

/obj/item/weapon/storage/bible/tome/atom_init()
	. = ..()
	rad_choices["Chapel looks"] = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "christianity_left")
	rad_choices["Runes"] = image(icon = 'icons/obj/rune.dmi', icon_state = "[rand(1, 6)]")
	rad_choices["Construction"] = image(icon = 'icons/turf/walls/cult_wall.dmi', icon_state = "box")

/obj/item/weapon/storage/bible/tome/examine(mob/user)
	if(iscultist(user) || isobserver(user))

	else
		..()

/obj/item/weapon/storage/bible/tome/attack_self(mob/user)
	if(religion && !choices_generated)
		building_choices()
		rune_choices()
		choices_generated = TRUE

	if(user.mind && user.mind.holy_role && user.mind.my_religion)
		choice_bible_func(user)
		return

	return ..()

// TODO: do func
/obj/item/weapon/storage/bible/tome/proc/rune_choices()
	return

/obj/item/weapon/storage/bible/tome/proc/building_choices()
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
	var/turf/targeted_turf = get_step(src, user.dir)

	if(istype(get_area(targeted_turf), /area/custom/cult))
		to_chat(user, "<span class='warning'>YOU CANT BUILD HERE!</span>")
		return

	for(var/datum/building_agent/B in build_choices_image)
		B.name = "[initial(B.name)] [B.favor_cost > 0 ? "[B.favor_cost] favors" : ""] [B.piety_cost > 0 ? "[B.piety_cost] piety" : ""]"

	var/datum/building_agent/choice = show_radial_menu(user, src, build_choices_image, tooltips = TRUE, require_near = TRUE)
	if(!choice)
		return

	if(choice.favor_cost > 0 && religion.favor < choice.favor_cost)
		to_chat(user, "<span class ='warning'>You need [choice.favor_cost - religion.favor] more favors.</span>")
		return
	if(choice.piety_cost > 0 && religion.piety < choice.piety_cost)
		to_chat(user, "<span class ='warning'>You need [choice.piety_cost - religion.piety] more piety.</span>")
		return

	if(ispath(choice.building_type, /turf))
		targeted_turf.ChangeTurf(choice.building_type)
	else
		new choice.building_type(targeted_turf)

	religion.favor -= choice.favor_cost
	religion.piety -= choice.piety_cost
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
