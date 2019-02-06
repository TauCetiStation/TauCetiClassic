/* Table parts and rack parts
 * Contains:
 *		Table Parts
 *		Reinforced Table Parts
 *		Glass Table Parts
 *		Wooden Table Parts
 *		Fancy Table Parts
 *		Black Fancy Table Parts
 *		Rack Parts
 */



/*
 * Table Parts
 */
/obj/item/weapon/table_parts/attackby(obj/item/weapon/W, mob/user)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		//SN src = null
		qdel(src)
	if (istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if (R.use(4))
			new /obj/item/weapon/table_parts/reinforced( user.loc )
			to_chat(user, "\blue You reinforce the [name].")
			qdel(src)
		else
			to_chat(user, "\red You need at least four rods to do this.")

/obj/item/weapon/table_parts/attack_self(mob/user)
	new /obj/structure/table( user.loc )
	user.drop_item()
	qdel(src)
	return


/*
 * Reinforced Table Parts
 */
/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		new /obj/item/stack/rods( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/reinforced/attack_self(mob/user)
	new /obj/structure/table/reinforced( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Glass Table Parts
 */
/obj/item/weapon/table_parts/glass/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/glass( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/glass/attack_self(mob/user)
	new /obj/structure/table/glass( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood( user.loc )
		qdel(src)

	if (istype(W, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/Grass = W
		Grass.use(1)
		new /obj/item/weapon/table_parts/wood/poker( src.loc )
		visible_message("<span class='notice'>[user] adds grass to the wooden table parts</span>")
		qdel(src)

/obj/item/weapon/table_parts/wood/attack_self(mob/user)
	new /obj/structure/table/woodentable( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Fancy Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/fancy/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/wood/fancy/attack_self(mob/user)
	new /obj/structure/table/woodentable/fancy( user.loc )
	user.drop_item()
	qdel(src)
	return

/obj/item/weapon/table_parts/wood/fancy/black/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/wood/fancy/black/attack_self(mob/user)
	new /obj/structure/table/woodentable/fancy/black( user.loc )
	user.drop_item()
	qdel(src)
	return


/*
 * Poker Table Parts
 */

/obj/item/weapon/table_parts/wood/poker/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood( user.loc )
		new /obj/item/stack/tile/grass( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/wood/poker/attack_self(mob/user)
	new /obj/structure/table/woodentable/poker( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Rack Parts
 */
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W, mob/user)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		qdel(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user)
	var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
	R.add_fingerprint(user)
	user.drop_item()
	qdel(src)
	return
