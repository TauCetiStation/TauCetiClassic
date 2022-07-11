/obj/structure/ch_feeder
	name = "Chicken Feeder"
	desc = "Co-co-co"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = FALSE
	anchored = TRUE
	var/food = 0

var/global/list/ch_feeder_list = list()

/obj/structure/ch_feeder/atom_init()
	..()
	ch_feeder_list += src

/obj/structure/ch_feeder/Destroy()
	ch_feeder_list -= src
	..()

/obj/structure/ch_feeder/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
		qdel(O)
		food += 1
	else
		..()
