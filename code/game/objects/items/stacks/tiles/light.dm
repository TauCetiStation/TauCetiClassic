/obj/item/stack/tile/light
	name = "light tile"
	singular_name = "light floor tile"
	desc = "A floor tile, made out off glass. It produces light."
	icon_state = "tile_e"
	w_class = ITEM_SIZE_NORMAL
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 60
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/on = 1
	var/state //0 = fine, 1 = flickering, 2 = breaking, 3 = broken
	turf_type = /turf/simulated/floor/light

/obj/item/stack/tile/light/atom_init()
	. = ..()
	if(prob(5))
		state = 3 //broken
	else if(prob(5))
		state = 2 //breaking
	else if(prob(10))
		state = 1 //flickering occasionally
	else
		state = 0 //fine

/obj/item/stack/tile/light/attackby(obj/item/I, mob/user, params)
	if(iscrowbar(I))
		if(!use(1))
			return
		new/obj/item/stack/sheet/metal(user.loc)
		new/obj/item/stack/light_w(user.loc)

	else
		return ..()
