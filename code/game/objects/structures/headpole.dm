/obj/structure/headpole
	name = "pole"
	icon = 'icons/obj/structures.dmi'
	icon_state = "metal_pike"
	desc = "How did this get here?"
	density = 0
	anchored = 1
	var/obj/item/weapon/twohanded/spear/spear = null
	var/obj/item/organ/external/head/head = null
	var/image/display_head = null

/obj/structure/headpole/atom_init(mapload, obj/item/organ/external/head/H, obj/item/weapon/twohanded/spear/S)
	. = ..()
	if(istype(H))
		head = H
		name = "[H.name]"
		if(H.brainmob)
			desc = "The severed head of [H.brainmob.real_name], crudely shoved onto the tip of a spear."
		else
			desc = "A severed [H], crudely shoved onto the tip of a spear."
		display_head = new (src)
		display_head.appearance = H.appearance
		display_head.transform = matrix()
		display_head.dir = SOUTH
		display_head.pixel_y = -3
		display_head.pixel_x = 1
		display_head.layer = 3
		display_head.plane = 0
		add_overlay(display_head)
	if(S)
		spear = S
		S.forceMove(src)
//		if(istype(S, /obj/item/weapon/spear/wooden))
//			icon_state = "wooden_pike"
	pixel_x = rand(-12,12)
	pixel_y = rand(0,20)
	var/matrix/M = matrix()
	M.Turn(rand(-20,20))
	transform = M

/obj/structure/headpole/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iscrowbar(W))
		to_chat(user, "You pry \the [head] off \the [spear].")
		if(head)
			head.forceMove(get_turf(src))
			head = null
		if(spear)
			spear.forceMove(get_turf(src))
			spear = null
		else
			new /obj/item/weapon/twohanded/spear/(get_turf(src))
		qdel(src)

/obj/structure/headpole/Destroy()
	if(head)
		qdel(head)
		head = null
	if(spear)
		qdel(spear)
		spear = null
	if(display_head)
		qdel(display_head)
		display_head = null
	return ..()

//obj/structure/headpole/with_head/atom_init()
//	var/obj/item/weapon/organ/head/H = new (src)
//	H.name = "head"
//	spear = new (src)
//	. = ..()

