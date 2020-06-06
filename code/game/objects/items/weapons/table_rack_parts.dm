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
/obj/item/weapon/table_parts/
	var/structure = /obj/structure/table
	var/drops = list(/obj/item/stack/sheet/metal = 2)

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W) && drops)
		for(var/drop in drops)
			for(var/i = 1 to drops[drop])
				var/obj/dropped_obj
				if(istype(drop, /obj/item/stack))
					dropped_obj = new drop( user.loc, merge = TRUE )
				else
					dropped_obj = new drop( user.loc )
				dropped_obj.add_fingerprint(user)
		qdel(src)
	if (istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if (R.use(4))
			var/obj/new_parts = new /obj/item/weapon/table_parts/reinforced( user.loc )
			new_parts.add_fingerprint(user)
			to_chat(user, "<span class='notice'>You reinforce the [name].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need at least four rods to do this.</span>")
	else
		..()

/obj/item/weapon/table_parts/attack_self(mob/user)
	if(do_after(user = user, target = src, delay = 3 SECONDS))
		var/obj/new_structure = new structure( user.loc )
		new_structure.add_fingerprint(user)
		user.drop_item()
		qdel(src)
	return


/*
 * Reinforced Table Parts
 */

/obj/item/weapon/table_parts/reinforced
	structure = /obj/structure/table/reinforced
	drops = list(/obj/item/stack/rods = 4, /obj/item/stack/sheet/metal = 2)

/*
 * Glass Table Parts
 */

/obj/item/weapon/table_parts/glass
	structure = /obj/structure/table/glass
	drops = list(/obj/item/stack/sheet/glass = 2)

/*
 * Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/Grass = W
		Grass.use(1)
		new /obj/item/weapon/table_parts/wood/poker( src.loc )
		visible_message("<span class='notice'>[user] adds grass to the wooden table parts</span>")
		qdel(src)
	else
		..()

/obj/item/weapon/table_parts/wood
	structure = /obj/structure/table/woodentable
	drops = list(/obj/item/stack/sheet/wood = 2)

/*
 * Fancy Wooden Table Parts
 */

/obj/item/weapon/table_parts/wood/fancy
	structure = /obj/structure/table/woodentable/fancy

/obj/item/weapon/table_parts/wood/fancy/black
	structure = /obj/structure/table/woodentable/fancy/black

/*
 * Poker Table Parts
 */

/obj/item/weapon/table_parts/wood/poker
	structure = /obj/structure/table/woodentable/poker
	drops = list(/obj/item/stack/sheet/wood = 2, /obj/item/stack/tile/grass = 1)

/*
 * Rack Parts
 */

/obj/item/weapon/table_parts/rack
	structure = /obj/structure/rack
	drops = list(/obj/item/stack/sheet/metal = 1)