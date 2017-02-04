/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby(obj/item/O, mob/user)
	..()
	if(istype(O,/obj/item/weapon/wirecutters))
		if(!use(1))
			return
		var/obj/item/weapon/cable_coil/CC = new/obj/item/weapon/cable_coil(user.loc)
		CC.amount = 5
		new/obj/item/stack/sheet/glass(user.loc)

	if(istype(O,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		if(M.amount < 1)
			return
		if(!src.use(1))
			return
		if(!M.use(1))
			return
		new/obj/item/stack/tile/light(user.loc)
