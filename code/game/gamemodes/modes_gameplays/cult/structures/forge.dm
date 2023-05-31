/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge_inactive"
	light_color = "#cc9338"
	light_power = 2
	light_range = 3

	var/datum/religion/religion

	// Maybe move it to /datum/religion?
	var/list/datum/building_agent/available_items = list()
	var/static/list/items_image

/obj/structure/cult/forge/atom_init()
	. = ..()
	init_subtypes(/datum/building_agent/tool/cult, available_items)

/obj/structure/cult/forge/examine(mob/user, distance)
	. = ..()
	if(!religion)
		return
	if(isliving(user)) // for ghosts
		if(!iscultist(user))
			return

	for(var/name in religion.aspects)
		var/datum/aspect/asp = religion.aspects[name]
		if(asp.god_desc)
			to_chat(user, "<font color='[asp.color]'>[name]</font>:<br>\t[asp.god_desc]")

/obj/structure/cult/forge/attack_hand(mob/user)
	if(!user.mind.holy_role || !user.my_religion)
		return

	if(!religion)
		religion = user.my_religion

	if(!items_image)
		to_chat(user, "<span class='notice'>The forge was set up.</span>")
		gen_images()

	create_def_items(user)

/obj/structure/cult/forge/proc/gen_images()
	items_image = list()
	for(var/datum/building_agent/B in available_items)
		var/atom/build = B.building_type
		items_image[B] = image(icon = initial(build.icon), icon_state = initial(build.icon_state))

/obj/structure/cult/forge/proc/create_def_items(mob/user)
	for(var/datum/building_agent/B in items_image)
		B.name = "[initial(B.name)] [B.get_costs()]"

	var/datum/building_agent/choice = show_radial_menu(user, src, items_image, tooltips = TRUE, require_near = TRUE)
	if(!choice)
		return

	if(!religion.check_costs(choice.favor_cost, choice.piety_cost, user))
		return

	if(istype(choice, /datum/building_agent/tool/cult/tome))
		religion.spawn_bible(loc)
	else
		new choice.building_type(loc)

	religion.adjust_favor(-choice.favor_cost)
	religion.adjust_piety(-choice.piety_cost)
	playsound(src, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	icon_state = "forge_active"
	VARSET_IN(src, icon_state, "forge_inactive", 10)
