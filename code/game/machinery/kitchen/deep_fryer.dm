/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	interact_offline = TRUE
	var/on = FALSE	//Is it deep frying already?
	var/obj/item/frying = null	//What's being fried RIGHT NOW?
	var/fry_time = 0.0


/obj/machinery/deepfryer/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/deepfryer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/deepfryer/Destroy()
	frying = null
	return ..()

/obj/machinery/deepfryer/examine(mob/user)
	..()
	if(frying)
		switch(fry_time)
			if(0 to 15)
				to_chat(user, "You can make out lightly-fried [frying] in the oil.")
			if(16 to 49)
				to_chat(user, "You can make out fried [frying] in the oil.")
			if(50 to 59)
				to_chat(user, "You can make out deep-fried [frying] in the oil.")
			if(60 to INFINITY)
				to_chat(user, "You fucked up, man.")

/obj/machinery/deepfryer/attackby(obj/item/I, mob/user)
	if(!anchored)
		if(iswrench(I))
			default_unfasten_wrench(user, I)
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is still active!</span>")
		return
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/deepfryholder))
		to_chat(user, "<span class='notice'>You cannot doublefry.</span>")
		return
	else if(iswrench(I))
		if(alert(user,"How do you want to use [I]?","You think...","Unfasten","Cook") == "Unfasten")
			default_unfasten_wrench(user, I)
			return
	if (ishuman(user) && !(I.flags & DROPDEL))
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		on = TRUE
		user.drop_item()
		frying = I
		frying.loc = src
		icon_state = "fryer_on"


/obj/machinery/deepfryer/process()
	..()
	if(frying)
		fry_time++
		if(fry_time == 30)
			playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
			visible_message("[src] dings!")
		else if (fry_time == 60)
			visible_message("[src] emits an acrid smell!")

/obj/machinery/deepfryer/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(frying)
		to_chat(user, "<span class='notice'>You eject [frying] from [src].</span>")
		var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/S = new(loc)
		S.appearance = frying.appearance
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
				S.name = "burned down mess"
				S.desc = "A heavily fried...something.  Who can tell anymore?"
		S.filling_color = S.color
		qdel(frying)
		icon_state = "fryer_off"
		user.put_in_hands(S)
		frying = null
		on = FALSE
		fry_time = 0
