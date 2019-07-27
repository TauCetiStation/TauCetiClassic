
/obj/item/queen_bee
	name = "queen bee packet"
	desc = "Place her into an apiary so she can get busy."
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed-kudzu"
	w_class = ITEM_SIZE_TINY

/obj/item/weapon/bee_net
	name = "bee net"
	desc = "For catching rogue bees."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_net"
	item_state = "bedsheet"
	w_class = ITEM_SIZE_NORMAL
	var/caught_bees = 0

/obj/item/weapon/bee_net/attack_self(mob/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	for(var/mob/living/simple_animal/bee/B in T)
		if(B.feral < 0)
			caught_bees += B.strength
			qdel(B)
			user.visible_message("<span class='notice'>[user] nets some bees.</span>","<span class='notice'>You net up some of the becalmed bees.</span>")
		else
			user.visible_message("<span class='warning'>[user] swings at some bees, they don't seem to like it.</span>","<span class='warning'>You swing at some bees, they don't seem to like it.</span>")
			B.feral = 5
			B.target_mob = user

/obj/item/weapon/bee_net/verb/empty_bees()
	set src in usr
	set name = "Empty bee net"
	set category = "Object"
	var/mob/living/carbon/M
	if(iscarbon(usr))
		M = usr

	while(caught_bees > 0)
		//release a few super massive swarms
		while(caught_bees > 5)
			var/mob/living/simple_animal/bee/B = new(src.loc)
			B.feral = 5
			B.target_mob = M
			B.strength = 6
			B.icon_state = "bees_swarm"
			caught_bees -= 6

		//what's left over
		var/mob/living/simple_animal/bee/B = new(src.loc)
		B.strength = caught_bees
		B.icon_state = "bees[B.strength]"
		B.feral = 5
		B.target_mob = M

		caught_bees = 0

/obj/item/apiary
	name = "moveable apiary"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary_item"
	item_state = "giftbag"
	w_class = ITEM_SIZE_HUGE

/obj/item/beezeez
	name = "bottle of BeezEez"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

/obj/item/beezeez/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/honeycomb
	name = "honeycomb"
	icon_state = "honeycomb"
	desc = "Dripping with sugary sweetness."

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/atom_init()
	. = ..()
	reagents.add_reagent("honey",10)
	reagents.add_reagent("nutriment", 0.5)
	reagents.add_reagent("sugar", 2)
	bitesize = 2

/datum/reagent/honey
	name = "Honey"
	id = "honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#ffff00"
