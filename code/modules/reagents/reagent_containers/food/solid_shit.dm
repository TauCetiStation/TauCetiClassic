/obj/item/weapon/reagent_containers/food/snacks/solid_shit
	name = "poo"
	desc = "It's a poo..."
	icon = 'icons/obj/poo.dmi'
	icon_state = "poop1"
	item_state = "poop"
	bitesize = 3
	var/random_icon_states = list("poop1", "poop2", "poop3", "poop4", "poop5", "poop6", "poop7")

/obj/item/weapon/reagent_containers/food/snacks/solid_shit/atom_init()
	. = ..()
	icon_state = pick(random_icon_states)
	reagents.add_reagent("poo", 5)

/obj/item/weapon/reagent_containers/food/snacks/solid_shit/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/blood/poo(loc)
	visible_message("<span class='rose'>[name] splats.</span>","<span class='rose'>You hear a splat.</span>")
	qdel(src)