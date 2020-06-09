//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/weapon/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."

/obj/item/weapon/storage/pill_bottle/happy/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/happy(src)

/obj/item/weapon/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."

/obj/item/weapon/storage/pill_bottle/zoom/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/zoom(src)
