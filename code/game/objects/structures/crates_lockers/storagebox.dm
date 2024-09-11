/obj/structure/storage_box
	icon = 'icons/obj/storage.dmi'
	icon_state = "densecrate"
	name = "Storage Crate"
	desc = "A heavy box used for storing stuff."
	density = TRUE
	layer = CONTAINER_STRUCTURE_LAYER
	resistance_flags = CAN_BE_HIT
	max_integrity = 100

/obj/structure/storage_box/attack_hand(mob/user)
	if(length(contents))
		if(do_after(user, 5, target = src))
			var/atom/movable/A = pick(contents)
			A.forceMove(src.loc)
			user.visible_message("<span class='notice'>[user] pulled \the [A] from \the [src]</span>", "<span class='notice'>You pulled \the [A] from \the [src]</span>")
			if(!length(contents))
				to_chat(user, "<span class='notice'>It was last item in the [src]!</span>")
				qdel(src)
		return
	return ..()

/obj/structure/storage_box/deconstruct(disassembled)
	dump_contents()
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/wood(loc, 4)
	..()

/obj/structure/storage_box/proc/dump_contents()
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(src.loc)

/obj/structure/storage_box/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				return
	for(var/atom/A in src)//pulls everything out of the locker and hits it with an explosion
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += A
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += A
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += A
	dump_contents()
	qdel(src)
