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

/obj/machinery/deepfryer/attackby(obj/item/I, mob/user, params)
	if(on)
		to_chat(user, "<span class='danger'>[src] is still active!</span>")
		return
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/deepfryholder))
		to_chat(user, "<span class='notice'>You cannot doublefry.</span>")
		return
	else if(istype(I, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = I
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/mob/living/A = G.assailant
			if(G.state > GRAB_NECK)
				user.drop_item()
				M.Weaken(8)
				A.Stun(3)
				M.apply_damage(80,BURN,"head")
				visible_message("<span class='danger'>[A.name] has dipped [M.name]'s face into the boiling oil!</span>")
				if(M.stat != DEAD)
					M.emote("scream",,, 1)
				M.attack_log += "\[[time_stamp()]\] <font color='orange'>[A.name] has dipped [M.name]'s face into the boiling oil ([A.ckey])</font>"
				A.attack_log += "\[[time_stamp()]\] <font color='red'>[A.name] has dipped [M.name]'s face into the boiling oil ([A.ckey])</font>"
				msg_admin_attack("[key_name(A)] has dipped [key_name(M)]'s face into boiling oil")
			else
				to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
				return
	else if(ishuman(user))
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
			playsound(src, "sound/machines/ding.ogg", 50, 1)
			visible_message("[src] dings!")
		else if (fry_time == 60)
			visible_message("[src] emits an acrid smell!")


/obj/machinery/deepfryer/attack_hand(mob/user)
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
		return