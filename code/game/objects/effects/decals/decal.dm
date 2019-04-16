/obj/effect/decal
	plane = FLOOR_PLANE
	anchored = TRUE
	var/no_scoop = FALSE   //if it has this, don't let it be scooped up
	var/no_clear = FALSE    //if it has this, don't delete it when its' scooped up
	var/list/scoop_reagents = null

/obj/effect/decal/atom_init()
	. = ..()
	if(scoop_reagents)
		create_reagents(100)
		reagents.add_reagent(scoop_reagents)

/obj/effect/decal/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || istype(I, /obj/item/weapon/reagent_containers/glass/beaker) || istype (I, /obj/item/weapon/reagent_containers/glass/bucket))
		scoop(I, user)

/obj/effect/decal/proc/scoop(obj/item/I, mob/user)
	if(reagents && I.reagents && !no_scoop)
		if(!reagents.total_volume)
			to_chat(user, "<span class='notice'>There isn't enough [src] to scoop up!</span>")
			return
		if(I.reagents.total_volume >= I.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[I] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You scoop [src] into [I]!</span>")
		reagents.trans_to(I, reagents.total_volume)
		if(!reagents.total_volume && !no_clear) //scooped up all of it
			qdel(src)

/*obj/effect/decal/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()*/