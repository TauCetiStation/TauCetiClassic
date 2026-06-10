/obj/structure/fittingroom
	name = "fittingroom"
	cases = list("раздевалка", "раздевалки", "раздевалке", "раздевалку", "раздевалкой", "раздевалке")
	desc = "Переодевайся вдали от любопытных глаз."
	icon = 'icons/obj/fittingroom.dmi'
	icon_state = "mapicon"
	density = FALSE
	anchored = TRUE

	resistance_flags = CAN_BE_HIT

	layer = BELOW_CONTAINERS_LAYER

	var/mutable_appearance/front
	var/mutable_appearance/door

	var/isopen = TRUE

/obj/structure/fittingroom/atom_init()
	. = ..()

	layer += 0.01
	icon_state = "back"
	front = mutable_appearance(icon, "front")
	front.layer = INFRONT_MOB_LAYER
	add_overlay(front)
	update_icon()

/obj/structure/fittingroom/update_icon()
	cut_overlay(door)

	door = mutable_appearance(icon, isopen ? "open" : "closed")
	door.layer = INFRONT_MOB_LAYER

	add_overlay(door)

/obj/structure/fittingroom/proc/toggle_door()
	isopen = !isopen
	update_icon()

/obj/structure/fittingroom/attack_hand(mob/user)
	var/mob/living/carbon/human/target = locate() in loc
	if(!target)
		return

	if(!isopen)
		return

	var/list/choices = list()
	choices["Одеться"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_increase")
	choices["Раздеться"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_decrease")

	var/obj/item/selection = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	toggle_door()
	switch(selection)
		if("Одеться")
			dress(user, target)
		if("Раздеться")
			undress(user, target)

/obj/structure/fittingroom/proc/dress(mob/user, mob/target)
	if(target.loc != loc || !user.Adjacent(target))
		toggle_door()
		return

	for(var/obj/item/I in loc)
		if(do_after(user, 1 SECONDS, FALSE, target))
			target.equip_to_appropriate_slot(I, TRUE)
			continue

	toggle_door()


/obj/structure/fittingroom/proc/undress(mob/user, mob/target)
	if(target.loc != loc || !user.Adjacent(target))
		toggle_door()
		return

	for(var/obj/item/I in user.get_equipped_items())
		if(!I.canremove)
			continue

		if(do_after(user, 1 SECONDS, FALSE, target))
			user.drop_from_inventory(I, loc, additional_pixel_x = rand(-6, 6), additional_pixel_y = rand(-6, 6))
			continue

	toggle_door()
