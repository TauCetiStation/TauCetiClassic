/obj/item/weapon/reagent_containers/spray/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = CONDUCT
	throwforce = 10
	w_class = ITEM_SIZE_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 10.0
	m_amt = 90
	safety = TRUE
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")

	triple_shot = TRUE
	spray_size = 3
	spray_sizes = list(3)

	amount_per_transfer_from_this = 10
	volume = 600

	spray_sound = 'sound/effects/refill.ogg'
	volume_modifier = -3

	chempuff_dense = FALSE

	spray_cloud_move_delay = 2
	spray_cloud_react_delay = 0

	var/random_overlay = TRUE
	var/reagent_inside = "aqueous_foam"
	var/FE_type = "red"

/obj/item/weapon/reagent_containers/spray/extinguisher/atom_init()
	. = ..()
	flags &= ~OPENCONTAINER|NOBLUDGEON
	if(random_overlay)
		cut_overlays()
		var/image/I = new(icon, "FE_overlay_[pick(1, 2, 3, 4)]")
		add_overlay(I)
	icon_state = "[initial(icon_state)][!safety]"
	reagents.add_reagent(reagent_inside, volume)

/obj/item/weapon/reagent_containers/spray/extinguisher/station_spawned/atom_init() // Station-spawned, as in, in-cabinets extinguishers shouldn't be full by default.
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("aqueous_foam", rand(volume * 0.5, volume))

/obj/item/weapon/reagent_containers/spray/extinguisher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		if(is_open_container())
			flags &= ~OPENCONTAINER
		else
			flags |= OPENCONTAINER
		to_chat(user, "<span class='notice'>You [is_open_container() ? "open" : "close"] the fill cap.</span>")
	else
		return ..()

/obj/item/weapon/reagent_containers/spray/extinguisher/examine(mob/user)
	..()
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	to_chat(user, "The fill cap is [is_open_container() ? "open" : "closed"].")

/obj/item/weapon/reagent_containers/spray/extinguisher/attack_self(mob/user)
	safety = !safety
	icon_state = "[initial(icon_state)][!safety]"
	to_chat(usr, "<span class = 'notice'>You switch the safety [safety ? "on" : "off"].</span>")

/obj/item/weapon/reagent_containers/spray/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE"
	item_state = "miniFE"
	hitsound = null // It is much lighter, after all.
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	force = 3.0
	m_amt = 0

	volume = 120

	random_overlay = FALSE
	FE_type = "mini"

/obj/item/weapon/reagent_containers/spray/extinguisher/mini/station_spawned/atom_init() // Station-spawned, as in, in-cabinets extinguishers shouldn't be full by default.
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("aqueous_foam", rand(volume * 0.5, volume))

/obj/item/weapon/reagent_containers/spray/extinguisher/golden
	name = "golden fire extinguisher"
	desc = "A rare golden extinguisher filled to the top with the finest champagne. Weighs a ton."
	icon_state = "goldenFE"
	item_state = "goldenFE"
	throwforce = 22
	force = 22

	volume = 800

	random_overlay = FALSE
	reagent_inside = "champagne"
	FE_type = "golden"
