/obj/structure/scrap_cube
	name = "compressed scrap"
	desc = "Cube made of compressed scrap"
	density = 1
	anchored = 0
	icon_state = "trash_cube_small"
	icon = 'icons/obj/structures/scrap/refine.dmi'

/obj/structure/scrap_cube/proc/make_pile()
	for(var/obj/item in contents)
		item.forceMove(loc)
	qdel(src)

/obj/structure/scrap_cube/New(var/newloc, var/size = 4)
	if(size > 10)
		icon_state = "trash_cube_large"
	..(newloc)

/obj/structure/scrap_cube/attackby(obj/item/W, mob/user)
	user.do_attack_animation(src)
	if(istype(W,/obj/item/weapon) && W.force >=8)
		visible_message("<span class='notice'>\The [user] smashes the [src], restoring it's original form.</span>")
		make_pile()
	else
		visible_message("<span class='notice'>\The [user] smashes the [src], but [W] is too weak to break it!</span>")

/obj/item/weapon/scrap_lump
	name = "unrefined scrap"
	desc = "This thing is messed up beyond any recognition. Into the grinder it goes!"
	icon = 'icons/obj/structures/scrap/refine.dmi'
	icon_state = "unrefined"
	w_class = 4

/obj/item/weapon/scrap_refined
	name = "refined scrap"
	desc = "This is ghetto gold!"
	icon = 'icons/obj/structures/scrap/refine.dmi'
	icon_state = "refined"
	w_class = 3