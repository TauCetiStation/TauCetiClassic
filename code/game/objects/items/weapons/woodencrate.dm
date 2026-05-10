/obj/item/weapon/woodencrate
	name = "wooden crate"
	cases = list("деревянный ящик", "деревянного ящика", "деревянному ящику", "деревянный ящик", "деревянным ящиком", "деревянном ящике")
	desc = "Ящик для хранения одинаковых предметов."
	icon = 'icons/obj/storage.dmi'
	icon_state = "woodencrate_open"
	w_class = SIZE_NORMAL

	max_integrity = 10
	resistance_flags = CAN_BE_HIT

	hit_particle_type = /particles/tool/digging/wood

	var/mutable_appearance/insides
	var/icon/insides_mask
	var/list/insides_boundaries = list(list(-7, 0), list(7, 6))
	var/icon/picture

	var/open = TRUE

	var/starttype
	var/startamount

	var/max_items = 15

/obj/item/weapon/woodencrate/atom_init()
	. = ..()

	if(starttype && startamount)
		for(var/i in 1 to startamount)
			new starttype(src)

		var/obj/item/I = contents[1]
		desc = "[initial(desc)] Содержит: [CASE(I, ACCUSATIVE_CASE)]"

	generate_icons()

/obj/item/weapon/woodencrate/Destroy()
	QDEL_NULL(insides)
	QDEL_NULL(picture)
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		I.forceMove(T)

	new /obj/item/stack/sheet/wood(T, 2)
	return ..()

/obj/item/weapon/woodencrate/proc/generate_icons()
	insides = mutable_appearance('icons/effects/32x32.dmi', "blank")
	insides_mask = icon(icon, "woodencrate_mask")
	insides.add_filter("insides_mask", 1, alpha_mask_filter(icon = icon(icon, "woodencrate_mask"), y = 14))
	insides.appearance_flags = KEEP_TOGETHER | RESET_COLOR

	picture = icon(icon, "woodencrate_paper")

	update_icon()

/obj/item/weapon/woodencrate/update_icon()
	cut_overlay(insides)
	insides.cut_overlays()

	cut_overlay(picture)

	if(open)
		icon_state = "woodencrate_open"

		for(var/obj/item/I in contents)
			insides.add_overlay(I)

		add_overlay(insides)
	else
		icon_state = "woodencrate_closed"

		if(!contents.len)
			return

		picture = icon(icon, "woodencrate_paper")

		var/obj/item/I = contents[1]
		var/icon/iconthing
		if(I.item_state_world)
			iconthing = icon(I.icon, I.item_state_world)
			picture.Blend(iconthing, ICON_OVERLAY, 1, 3)
		else
			iconthing = icon(I.icon, I.icon_state)
			iconthing.Scale(12, 12)
			picture.Blend(iconthing, ICON_OVERLAY, 11, 13)

		add_overlay(picture)

/obj/item/weapon/woodencrate/proc/can_be_inserted(obj/item/W)
	if(!istype(W) || (W.flags & ABSTRACT) || W.anchored)
		return FALSE//Not an item

	if(loc == W)
		return FALSE //Means the item is already in the storage item

	if(istype(W, /obj/item/weapon/packageWrap) || istagger(W))
		return FALSE

	if (W.flags_2 & CANT_BE_INSERTED)
		return FALSE

	if (W.w_class > SIZE_SMALL)
		return FALSE

	if(contents.len >= max_items)
		return FALSE

	if(contents.len)
		var/obj/item/I = contents[1]
		if(W.type != I.type)
			return FALSE

	return TRUE

/obj/item/weapon/woodencrate/attackby(obj/item/weapon/W, mob/user)
	if(!open && isprying(W))
		if(user.is_busy()) return
		if(W.use_tool(src, user, 15, volume = 50, quality = QUALITY_PRYING, particle_type = /particles/tool/digging/wood))
			open = TRUE
			update_icon()
			new /obj/item/stack/sheet/wood(get_turf(src), 1)
			return

	if(open && istype(W, /obj/item/stack/sheet/wood))
		if(user.is_busy()) return
		var/obj/item/stack/sheet/wood/plank = W
		if(plank.use_tool(src, user, 15, volume = 100, particle_type = /particles/tool/digging/wood))
			if(!plank.use(1))
				return

			open = FALSE
			update_icon()
			return

	if(istype(W, /obj/item/weapon/storage) && !istype(W, /obj/item/weapon/storage/bag/plants))
		return ..()

	if(open)
		if(contents.len)
			var/obj/item/I = contents[1]
			if(istype(W, /obj/item/weapon/storage/bag/plants))
				var/obj/item/weapon/storage/bag/plants/P = W

				for(var/obj/item/T in P.contents)
					if(contents.len >= max_items)
						return ..()
					if(T.type == I.type)
						P.remove_from_storage(T, src)

				update_icon()
				return

		if(!can_be_inserted(W))
			return ..()

		desc = "[initial(desc)] Содержит: [CASE(W, ACCUSATIVE_CASE)]"
		user.drop_from_inventory(W, src)
		W.pixel_x = rand(insides_boundaries[1][1], insides_boundaries[2][1])
		W.pixel_y = rand(insides_boundaries[1][2], insides_boundaries[2][2])
		update_icon()
		return

	return ..()

/obj/item/weapon/woodencrate/attack_hand(mob/user)
	if(!open || !contents.len)
		return ..()

	var/list/items = list()
	items["Pickup"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup")

	var/obj/item/thing = contents[rand(1, contents.len)]
	items[thing] = image(icon = thing.icon, icon_state = thing.icon_state)

	var/obj/item/selection = show_radial_menu(user, src, items, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	if(selection == "Pickup" || !open)
		return ..()

	if(ishuman(user))
		user.put_in_hands(selection)
	else
		selection.forceMove(get_turf(src))

	update_icon()


//Wooden crate presets
/obj/item/weapon/woodencrate/potato
	icon_state = "woodencrate_closed"
	open = FALSE
	starttype = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	startamount = 15

/obj/item/weapon/woodencrate/beer
	icon_state = "woodencrate_closed"
	open = FALSE
	starttype = /obj/item/weapon/reagent_containers/food/drinks/bottle/beer
	startamount = 10

/obj/item/weapon/woodencrate/banana
	icon_state = "woodencrate_closed"
	open = FALSE
	starttype = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	startamount = 15
