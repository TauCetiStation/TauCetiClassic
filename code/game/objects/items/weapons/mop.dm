/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0


/obj/item/weapon/mop/New()
	create_reagents(5)


obj/item/weapon/mop/proc/clean(turf/simulated/A)
	if(reagents.has_reagent("water", 1))
		A.clean_blood()
		A.dirt = 0
		for(var/obj/effect/O in A)
			if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
				qdel(O)
	reagents.reaction(A, TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/weapon/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return

		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")

		if(do_after(user, 40, target = A))
			if(A)
				clean(get_turf(A))
			to_chat(user, "<span class='notice'>You have finished mopping!</span>")


/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/kitchen/utensil/fork))
		return
	..()


/obj/item/weapon/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	icon_state = "advmop"
	item_state = "mop"
	force = 6.0
	throwforce = 10.0
	throw_range = 10.0
