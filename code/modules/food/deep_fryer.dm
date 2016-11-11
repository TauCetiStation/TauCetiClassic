/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	var/on = FALSE	//Is it deep frying already?
	var/obj/item/frying = null	//What's being fried RIGHT NOW?
	var/fry_time = 0.0


/obj/machinery/deepfryer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/deep_fryer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()


/obj/machinery/deepfryer/examine()
	..()
	if(frying)
		usr << "You can make out [frying] in the oil."


/obj/machinery/deepfryer/attackby(obj/item/I, mob/user)
	if(on)
		user << "<span class='notice'>[src] is still active!</span>"
		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/deepfryholder))
		user << "<span class='notice'>You cannot doublefry.</span>"
		return

	else
		user << "<span class='notice'>You put [I] into [src].</span>"
		on = TRUE
		user.drop_item()
		frying = I
		frying.loc = src
		icon_state = "fryer_on"
		fry_time++

/obj/machinery/deepfryer/attack_hand(mob/user)
	if(frying)
		user << "<span class='notice'>You eject [frying] from [src].</span>"
		if(frying.loc == src)
			var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/S = new(get_turf(src))
			S.icon = frying.icon
			S.overlays = frying.overlays
			S.icon_state = frying.icon_state
			S.desc = frying.desc
			switch(fry_time)
				if(0 to 15)
					S.color = rgb(166,103,54)
					S.name = "lightly-fried [frying.name]"
				if(16 to 49)
					S.color = rgb(103,63,24)
					S.name = "fried [frying.name]"
				if(50 to 59)
					S.color = rgb(63, 23, 4)
					S.name = "deep-fried [frying.name]"
				if(60 to INFINITY)
					S.color = rgb(33,19,9)
					S.name = "the physical manifestation of the very concept of fried foods"
					S.desc = "A heavily fried...something.  Who can tell anymore?"
			S.filling_color = S.color
			if(istype(frying, /obj/item/weapon/reagent_containers/food/snacks/))
				qdel(frying)
			else
				frying.loc = S

			icon_state = "fryer_off"
			user.put_in_hands(S)
			S = null
			frying = null
			on = FALSE
			fry_time = 0
			return