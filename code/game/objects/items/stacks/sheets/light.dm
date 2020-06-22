/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = ITEM_SIZE_NORMAL
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby(obj/item/I, mob/user, params)
	if(iswirecutter(I))
		if(!use(1))
			return
		new/obj/item/stack/cable_coil/random(user.loc, 5)
		new/obj/item/stack/sheet/glass(user.loc)

	else if(istype(I,/obj/item/stack/sheet/metal))
		var/list/resources_to_use = list()
		resources_to_use[I] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		new/obj/item/stack/tile/light(user.loc)

	else
		return ..()
